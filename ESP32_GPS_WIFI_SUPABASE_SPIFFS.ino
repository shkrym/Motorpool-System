#include <WiFi.h>
#include <HTTPClient.h>
#include "SPIFFS.h"
#include "time.h"
#include <TinyGPS++.h>
#include <vector>

#define GPS_RX_PIN 17
#define GPS_TX_PIN 16
#define GPS_BAUD   9600

// ---------- CONFIG ----------
const char* WIFI_SSID = "realme C67";
const char* WIFI_PASS = "87654321";
const char* SUPABASE_URL = "https://ggpjhaagszuoacafuihq.supabase.co/rest/v1/gps_data";
const char* ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncGpoYWFnc3p1b2FjYWZ1aWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxMDIwNTQsImV4cCI6MjA3NTY3ODA1NH0.Ujoz5Lal_iWyrale7aJh2aABt-yr5fc9pBG-AKPzXqQ";

// === KEY CHANGE: Read GPS more frequently ===
const unsigned long GPS_READ_INTERVAL_MS = 10000UL;  // Read GPS every 10 seconds
const unsigned long UPLOAD_INTERVAL_MS = 30000UL;    // Upload every 30 seconds

const char* QUEUE_PATH = "/queue.txt";
const char* VEHICLE_ID = "9ed8941c-3ffd-4939-8993-40ea005b4b2c";

// NTP config
const char* NTP_SERVER = "time.google.com";
const long GMT_OFFSET_SEC = 8 * 3600;
const int DAYLIGHT_OFFSET_SEC = 0;

// === GPS Buffer Structure ===
struct GPSReading {
  float lat;
  float lng;
  String timestamp;
};

std::vector<GPSReading> gpsBuffer; // Temporary buffer between reads
unsigned long lastGPSReadMillis = 0;
unsigned long lastUploadMillis = 0;

TinyGPSPlus gps;

// --------- Timestamp Helper ----------
String getISOUTCTimestamp() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return String();
  }
  char buf[30];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}

// ---------- SPIFFS Queue Functions ----------
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
  Serial.println("Queued: " + jsonLine);
}

std::vector<String> readQueueLines() {
  std::vector<String> lines;
  if (!SPIFFS.exists(QUEUE_PATH)) return lines;

  File f = SPIFFS.open(QUEUE_PATH, FILE_READ);
  if (!f) return lines;

  while (f.available()) {
    String line = f.readStringUntil('\n');
    line.trim();
    if (line.length() > 0) lines.push_back(line);
  }
  f.close();
  return lines;
}

bool overwriteQueueWith(const std::vector<String> &remaining) {
  const char* tmpPath = "/queue_tmp.txt";
  File t = SPIFFS.open(tmpPath, FILE_WRITE);
  if (!t) return false;
  
  for (auto &ln : remaining) {
    t.println(ln);
  }
  t.close();

  if (SPIFFS.exists(QUEUE_PATH)) SPIFFS.remove(QUEUE_PATH);
  SPIFFS.rename(tmpPath, QUEUE_PATH);
  return true;
}

void clearQueue() {
  if (SPIFFS.exists(QUEUE_PATH)) {
    SPIFFS.remove(QUEUE_PATH);
    Serial.println("Queue cleared");
  }
}

// ---------- Networking ----------
void initTime() {
  configTime(GMT_OFFSET_SEC, DAYLIGHT_OFFSET_SEC, NTP_SERVER);
  Serial.println("Time sync requested...");
  delay(1500);
}

bool postJSON(const String &jsonPayload, int &httpResponseCode, String &responseBody) {
  if (WiFi.status() != WL_CONNECTED) return false;

  HTTPClient http;
  http.begin(String(SUPABASE_URL));
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", ANON_KEY);
  http.addHeader("Authorization", "Bearer " + String(ANON_KEY));

  httpResponseCode = http.POST(jsonPayload);
  responseBody = http.getString();
  http.end();

  return (httpResponseCode >= 200 && httpResponseCode < 300);
}

// ---------- Build Payload Helper ----------
String buildPayload(float lat, float lng, String ts, bool isQueued) {
  String payload = "{\"lat\":" + String(lat, 6) + ",\"long\":" + String(lng, 6);
  if (ts.length()) payload += ",\"timestamp\"😕"" + ts + "\"";
  payload += ",\"vehicle_id\"😕"" + String(VEHICLE_ID) + "\"";
  if (isQueued) payload += ",\"is_queued\":true";
  payload += "}";
  return payload;
}

// ---------- Drain Queue ----------
bool drainQueue() {
  std::vector<String> lines = readQueueLines();
  if (lines.empty()) return true;

  Serial.printf("Draining queue: %u entries\n", lines.size());

  std::vector<String> remaining;
  for (size_t i = 0; i < lines.size(); i++) {
    int code;
    String resp;
    bool ok = postJSON(lines[i], code, resp);
    
    if (!ok) {
      // Keep this and all following
      for (size_t j = i; j < lines.size(); j++) {
        remaining.push_back(lines[j]);
      }
      break;
    }
    Serial.println("Uploaded queued: " + lines[i].substring(0, 50) + "...");
  }

  if (remaining.empty()) {
    clearQueue();
    return true;
  } else {
    overwriteQueueWith(remaining);
    return false;
  }
}

// ---------- Read GPS Function ----------
void readGPS() {
  // Read all available GPS data from Serial1
  while (Serial1.available() > 0) {
    gps.encode(Serial1.read());
  }
}

// ========== MAIN UPLOAD LOGIC (IMPROVED) ==========
void processGPSBuffer() {
  if (gpsBuffer.empty()) return;

  bool hasWiFi = (WiFi.status() == WL_CONNECTED);

  if (hasWiFi) {
    Serial.println("📡 WiFi connected - uploading buffer...");
    
    // Upload each reading in buffer
    for (const auto& reading : gpsBuffer) {
      String payload = buildPayload(reading.lat, reading.lng, reading.timestamp, false);
      int code;
      String resp;
      bool ok = postJSON(payload, code, resp);
      
      if (ok) {
        Serial.println("✓ Uploaded live: " + String(reading.lat, 6) + ", " + String(reading.lng, 6));
      } else {
        Serial.println("✗ Upload failed, queuing...");
        String queuedPayload = buildPayload(reading.lat, reading.lng, reading.timestamp, true);
        appendToQueue(queuedPayload);
      }
    }
    
    // After uploading current buffer, drain old queue
    if (SPIFFS.exists(QUEUE_PATH)) {
      Serial.println("📤 Draining old queue...");
      drainQueue();
    }
    
  } else {
    Serial.println("📵 No WiFi - saving all to queue...");
    
    // No WiFi: save everything to SPIFFS
    for (const auto& reading : gpsBuffer) {
      String payload = buildPayload(reading.lat, reading.lng, reading.timestamp, true);
      appendToQueue(payload);
    }
  }

  // Clear buffer after processing
  gpsBuffer.clear();
}

// ---------- Setup ----------
void setup() {
  Serial.begin(115200);
  Serial1.begin(GPS_BAUD, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN);
  Serial.println("\n🚗 GPS Tracker with Continuous Logging");
  Serial.println("========================================");
  
  if (!initSPIFFS()) {
    Serial.println("❌ SPIFFS init failed - aborting");
    while(1) delay(1000);
  }
  Serial.println("✓ SPIFFS initialized");

  // Connect WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("Connecting to WiFi");
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(500);
    Serial.print(".");
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi connected: " + WiFi.localIP().toString());
    initTime();
  } else {
    Serial.println("\n⚠️  WiFi NOT connected - will queue data");
  }

  Serial.println("📍 Waiting for GPS signal...");
  lastGPSReadMillis = millis();
  lastUploadMillis = millis();
}

// ---------- Main Loop ----------
void loop() {
  unsigned long now = millis();
  
  // ===== STEP 1: ALWAYS Read GPS (kahit walang WiFi) =====
  readGPS();
  
  // ===== STEP 2: Every 10 seconds, check if we have valid GPS =====
  if (now - lastGPSReadMillis >= GPS_READ_INTERVAL_MS) {
    lastGPSReadMillis = now;
    
    if (gps.location.isUpdated() && gps.location.isValid()) {
      float lat = gps.location.lat();
      float lng = gps.location.lng();
      String ts = getISOUTCTimestamp();
      
      // Add to buffer
      GPSReading reading;
      reading.lat = lat;
      reading.lng = lng;
      reading.timestamp = ts;
      gpsBuffer.push_back(reading);
      
      Serial.printf("📍 GPS: %.6f, %.6f (Buffer: %d)\n", lat, lng, gpsBuffer.size());
    } else {
      Serial.println("⚠️  GPS signal weak or invalid");
    }
  }
  
  // ===== STEP 3: Every 30 seconds, upload/queue the buffer =====
  if (now - lastUploadMillis >= UPLOAD_INTERVAL_MS) {
    lastUploadMillis = now;
    
    Serial.println("\n⏰ Upload interval reached");
    processGPSBuffer();
    
    // Try to reconnect WiFi if disconnected
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("🔄 Attempting WiFi reconnect...");
      WiFi.reconnect();
      delay(3000);
      if (WiFi.status() == WL_CONNECTED) {
        Serial.println("✓ WiFi reconnected!");
        initTime();
      }
    }
  }
  
  delay(100); // Small delay for stability
}