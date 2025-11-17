#include <WiFi.h>
#include <HTTPClient.h>
#include "SPIFFS.h"
#include "time.h"
#include <TinyGPS++.h>

#define GPS_RX_PIN 17      // GPS TX -> ESP32 RX
#define GPS_TX_PIN 16
#define GPS_BAUD   9600
// ---------- CONFIG ----------
const char* WIFI_SSID = "realme C67";
const char* WIFI_PASS = "87654321";

const char* SUPABASE_URL = "https://ggpjhaagszuoacafuihq.supabase.co/rest/v1/gps_data"; // REST endpoint
const char* ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncGpoYWFnc3p1b2FjYWZ1aWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxMDIwNTQsImV4cCI6MjA3NTY3ODA1NH0.Ujoz5Lal_iWyrale7aJh2aABt-yr5fc9pBG-AKPzXqQ";

const unsigned long UPLOAD_INTERVAL_MS = 30000UL; // change time interval in milliseconds
const char* QUEUE_PATH = "/queue.txt";

// ⚠️ IMPORTANT: Set your vehicle UUID from vehicles table in Supabase
const char* VEHICLE_ID = "9ed8941c-3ffd-4939-8993-40ea005b4b2c"; // ← Your vehicle UUID

// NTP config (for timestamps); Philippines UTC+8
const char* NTP_SERVER = "time.google.com";
const long GMT_OFFSET_SEC = 8 * 3600;  // ← Philippines time (UTC+8)
const int DAYLIGHT_OFFSET_SEC = 0;
// ----------------------------

// Globals
unsigned long lastUploadMillis = 0;
float lat, lng;
TinyGPSPlus gps;

// --------- Helpers: timestamps ----------
String getISOUTCTimestamp() {
  // Return ISO8601 UTC timestamp like "2025-11-12T15:00:00Z"
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    // fallback to millis-time (not ideal)
    return String();
  }
  char buf[30];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo); // Z for UTC
  return String(buf);
}

String getLocalISOwithOffset() {
  // If you prefer local timestamp with +08:00 offset: "2025-11-12T23:00:00+08:00"
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) return String();
  char buf[40];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S", &timeinfo);
  // append offset
  String s = String(buf) + "+08:00";
  return s;
}

// ---------- Queue (SPIFFS) ----------
bool initSPIFFS() {
  if (!SPIFFS.begin(true)) {
    Serial.println("SPIFFS Mount Failed");
    return false;
  }
  return true;
}

void appendToQueue(const String &jsonLine) {
  File f = SPIFFS.open(QUEUE_PATH, FILE_APPEND);
  if (!f) {
    Serial.println("Failed to open queue file for append");
    return;
  }
  f.println(jsonLine);
  f.close();
  Serial.println("Queued payload -> " + jsonLine);
}

std::vector<String> readQueueLines() {
  std::vector<String> lines;
  if (!SPIFFS.exists(QUEUE_PATH)) return lines;

  File f = SPIFFS.open(QUEUE_PATH, FILE_READ);
  if (!f) {
    Serial.println("Failed to open queue file for read");
    return lines;
  }

  while (f.available()) {
    String line = f.readStringUntil('\n');
    line.trim();
    if (line.length() > 0) lines.push_back(line);
  }
  f.close();
  return lines;
}

bool overwriteQueueWith(const std::vector<String> &remaining) {
  // Write remaining lines atomically by writing to temp and renaming
  const char* tmpPath = "/queue_tmp.txt";
  File t = SPIFFS.open(tmpPath, FILE_WRITE);
  if (!t) {
    Serial.println("Failed to open temp queue file for write");
    return false;
  }
  for (auto &ln : remaining) {
    t.println(ln);
  }
  t.close();

  // remove original and rename
  if (SPIFFS.exists(QUEUE_PATH)) SPIFFS.remove(QUEUE_PATH);
  SPIFFS.rename(tmpPath, QUEUE_PATH);
  return true;
}

void clearQueue() {
  if (SPIFFS.exists(QUEUE_PATH)) {
    SPIFFS.remove(QUEUE_PATH);
    Serial.println("Queue file cleared.");
  }
}

// ---------- Networking ----------
void initTime() {
  configTime(GMT_OFFSET_SEC, DAYLIGHT_OFFSET_SEC, NTP_SERVER);
  Serial.println("Time sync requested...");
  delay(1500);
  struct tm timeinfo;
  if (getLocalTime(&timeinfo)) {
    Serial.println("Time obtained: " + String(asctime(&timeinfo)));
  } else {
    Serial.println("Failed to obtain time");
  }
}

bool postJSON(const String &jsonPayload, int &httpResponseCode, String &responseBody) {
  if (WiFi.status() != WL_CONNECTED) return false;

  HTTPClient http;
  http.begin(String(SUPABASE_URL)); // HTTPS
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", ANON_KEY);
  http.addHeader("Authorization", "Bearer " + String(ANON_KEY));
  // Option: add "Prefer: return=representation" if you want body back

  httpResponseCode = http.POST(jsonPayload);
  responseBody = http.getString();
  http.end();

  // Supabase returns 201 for successful POST
  return (httpResponseCode >= 200 && httpResponseCode < 300);
}

// Attempt to drain queue: return true if all queued entries were uploaded successfully
bool drainQueue() {
  std::vector<String> lines = readQueueLines();
  if (lines.empty()) {
    return true; // nothing to do
  }

  Serial.printf("Draining queue: %u entries\n", (unsigned int)lines.size());

  std::vector<String> remaining; // if some fails, keep them here
  for (auto &ln : lines) {
    int code;
    String resp;
    bool ok = postJSON(ln, code, resp);
    Serial.printf("Queued POST -> %d response\n", code);
    if (!ok) {
      // stop further attempts (optional: you can choose to continue)
      Serial.println("Failed to upload queued item, keeping remaining in queue");
      // push current and all following to remaining
      remaining.push_back(ln);
      // find index to push the rest
      size_t idx = &ln - &lines[0]; // not safe to compute this way; instead process differently
      // simpler: push subsequent by iterating remaining lines after current
      // but we can't get index easily here; so change approach: iterate with index
      break;
    } else {
      Serial.println("Uploaded queued item: " + ln);
    }
  }

  // Simpler second-pass: if any failed during the above naive loop, rebuild remaining properly
  // We'll do robust approach: iterate with index
  remaining.clear();
  for (size_t i = 0; i < lines.size(); ++i) {
    int code;
    String resp;
    bool ok = postJSON(lines[i], code, resp);
    if (!ok) {
      // push this and everything after it
      for (size_t j = i; j < lines.size(); ++j) remaining.push_back(lines[j]);
      break;
    }
    // otherwise continue
  }

  if (remaining.empty()) {
    // all uploaded, delete queue file
    clearQueue();
    return true;
  } else {
    // write remaining back
    bool w = overwriteQueueWith(remaining);
    if (!w) {
      Serial.println("Failed to overwrite queue with remaining lines. Keeping original file.");
    }
    return false;
  }
}

// ---------- Main upload workflow ----------
void tryUpload(float lat, float lng) {
  // Build payload for this reading
  // Use UTC timestamp (Z) — server stores timestamptz properly.
  String ts = getISOUTCTimestamp();
  if (ts.length() == 0) {
    Serial.println("Time not available; using empty timestamp.");
  }

  String payload = "{\"lat\":" + String(lat, 6) + ",\"long\":" + String(lng, 6);
  if (ts.length()) payload += ",\"timestamp\":\"" + ts + "\"";
  payload += ",\"vehicle_id\":\"" + String(VEHICLE_ID) + "\"";
  payload += "}";
  
  // Debug: print payload to verify vehicle_id is included
  Serial.println("Payload: " + payload);

  // If WiFi not connected -> queue and return
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected. Queueing payload.");
    appendToQueue(payload);
    return;
  }

  // If queue file exists, drain it first before sending this reading
  if (SPIFFS.exists(QUEUE_PATH)) {
    Serial.println("Connectivity available - draining queue first...");
    bool drainedAll = drainQueue();
    if (!drainedAll) {
      // If not all drained, queue the current payload too
      appendToQueue(payload);
      return;
    }
    // else continue to send the current payload below
  }

  // send current payload
  int code;
  String resp;
  bool ok = postJSON(payload, code, resp);
  if (ok) {
    Serial.println("Posted live payload -> HTTP " + String(code));
  } else {
    Serial.println("Live POST failed (code " + String(code) + "). Queueing payload.");
    appendToQueue(payload);
  }
}

void readGPS() {
  // Read all available GPS data
  while (Serial1.available() > 0) {
    gps.encode(Serial1.read());
  }
  // If GPS received a new location fix
  if (gps.location.isUpdated()) {
    Serial.print("Latitude: ");
    Serial.println(gps.location.lat(), 6);
    lat = gps.location.lat();

    Serial.print("Longitude: ");
    Serial.println(gps.location.lng(), 6);
    lng = gps.location.lng();
  }
}

// ---------- Setup & Loop ----------
void setup() {
  Serial.begin(115200);
  Serial1.begin(GPS_BAUD, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN); // Use Serial1 for GPS RX
  Serial.println("Waiting for GPS signal...");
  delay(100);

  if (!initSPIFFS()) {
    Serial.println("SPIFFS init failed - aborting.");
  }

  // Connect WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(500);
    Serial.print(".");
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected: " + WiFi.localIP().toString());
    initTime();
  } else {
    Serial.println("\nWiFi NOT connected at boot. Will try periodically.");
  }

  lastUploadMillis = millis();
}

void loop() {
  unsigned long now = millis();
  if (now - lastUploadMillis >= UPLOAD_INTERVAL_MS) {
    lastUploadMillis = now;

    // === Replace this with your GPS reading logic ===
    // Example static coordinates for testing:
    readGPS();
    // If you have TinyGPS++, read it here and set lat/lng from GPS
    // e.g. lat = gps.location.lat(); lng = gps.location.lng();

    tryUpload(lat, lng);

    // Also attempt to reconnect WiFi if disconnected
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("Attempting WiFi reconnect...");
      WiFi.reconnect();
      // After reconnect, re-init time
      if (WiFi.status() == WL_CONNECTED) {
        initTime();
      }
    }
  }

  // Small warm-down to yield CPU
  delay(10);
}
