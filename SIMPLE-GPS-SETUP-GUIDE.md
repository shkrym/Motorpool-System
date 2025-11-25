# 🎯 Simple GPS Vehicle Tracking Setup

Since your Arduino is already working and sending GPS data, you only need **3 simple steps**!

---

## ✅ Step 1: Update Database (2 minutes)

### 1.1 Run SQL Migration

1. Open **Supabase Dashboard** → **SQL Editor**
2. Copy ALL contents from `link-vehicle-to-gps.sql`
3. Paste and click **RUN**
4. Wait for "Success. No rows returned" (or similar success message)

This adds:
- ✅ `vehicle_id` column to your `gps_data` table
- ✅ `vehicle_latest_gps` view for the map
- ✅ `get_vehicle_route()` function for route history

**✅ SQL Fixed!** The function now uses `gps_timestamp` instead of `timestamp` (reserved keyword).

### 1.2 Get Your Vehicle UUID

Run this query to find your vehicle's UUID:

```sql
SELECT id, vehicle_id, plate_number 
FROM vehicles 
ORDER BY created_at DESC;
```

**Copy the UUID** (looks like: `550e8400-e29b-41d4-a716-446655440000`)

---

## ✅ Step 2: Update Arduino Code (1 minute)

### 2.1 Open Your Arduino File

Open `ESP32_GPS_WIFI_SUPABASE_SPIFFS.ino`

### 2.2 Find This Line (around line 22):

```cpp
const char* VEHICLE_UUID = "YOUR-VEHICLE-UUID-HERE"; // ⚠️ CHANGE THIS!
```

### 2.3 Replace with Your Vehicle UUID:

```cpp
const char* VEHICLE_UUID = "550e8400-e29b-41d4-a716-446655440000"; // Your actual UUID
```

### 2.4 Upload to Arduino

1. Click **Upload** button
2. Wait for "Done uploading"
3. Open **Serial Monitor** (115200 baud)
4. Look for: "Posted live payload -> HTTP 201"

**✅ Arduino is now sending vehicle_id with GPS data!**

---

## ✅ Step 3: View on Map (30 seconds)

### 3.1 Open Your Motorpool App

1. Log in to your Motorpool System
2. Click **"Live GPS Map"** in the left sidebar

### 3.2 You Should See:

- ✅ Interactive map loads
- ✅ Your vehicle appears in the left sidebar
- ✅ Vehicle marker shows on the map
- ✅ Click vehicle → map centers on it
- ✅ Marker updates every 30 seconds

---

## 🧪 Verification

### Check GPS Data Has vehicle_id

Run in Supabase SQL Editor:

```sql
-- Check latest GPS data
SELECT 
  id,
  vehicle_id,
  lat,
  long,
  timestamp,
  created_at
FROM gps_data 
ORDER BY created_at DESC 
LIMIT 5;
```

**You should see:**
- `vehicle_id` filled with your vehicle's UUID
- `lat` and `long` with coordinates
- `timestamp` with current time

### Check Vehicle Appears on Map

```sql
-- Check vehicle shows in view
SELECT * FROM vehicle_latest_gps;
```

**You should see:**
- Your vehicle with plate number
- latitude and longitude
- device_timestamp (recent)
- seconds_since_update (small number)

---

## 🎉 That's It!

Your GPS tracking is now live! Here's what you can do:

### On the Live Map:

✅ **Search vehicles** - Type plate number or vehicle code  
✅ **Click markers** - See vehicle details  
✅ **View route history** - Click "View Route History (24h)"  
✅ **Auto-refresh** - Updates every 30 seconds automatically  
✅ **Status colors**:
- 🟢 Green = Active (< 1 min old)
- 🟡 Yellow = Recent (1-5 min old)
- 🔴 Red = Stale (> 5 min old)

---

## 🔧 Troubleshooting

### Vehicle Not Showing on Map?

**Check 1: Is Arduino sending vehicle_id?**
```sql
SELECT vehicle_id FROM gps_data WHERE vehicle_id IS NOT NULL LIMIT 1;
```
- If NULL → Arduino code not updated
- If shows UUID → Good! ✅

**Check 2: Does UUID match?**
```sql
-- This should return 1 row (your vehicle)
SELECT v.plate_number, g.lat, g.long 
FROM vehicles v
JOIN gps_data g ON v.id = g.vehicle_id
ORDER BY g.created_at DESC
LIMIT 1;
```
- If no rows → UUID mismatch
- If shows data → Good! ✅

**Check 3: Is view working?**
```sql
SELECT * FROM vehicle_latest_gps;
```
- If empty → Check joins above
- If shows vehicle → Good! ✅

### Arduino Serial Monitor Shows Error?

Check the payload being sent:
```
Look for line in Serial Monitor:
Queued payload -> {"lat":14.599524,"long":120.984219,"timestamp":"2025-11-16T12:00:00Z","vehicle_id":"YOUR-UUID"}
```

**Make sure `vehicle_id` is included!**

### Map Loads But No Markers?

1. Open browser console (F12)
2. Look for errors
3. Check if Leaflet.js loaded: `npm list leaflet`
4. Refresh the page (Ctrl+F5)

---

## 📊 Monitor Your GPS System

### Daily Check:
```sql
-- See all vehicles with GPS today
SELECT 
  vehicle_code,
  plate_number,
  latitude,
  longitude,
  device_timestamp,
  seconds_since_update
FROM vehicle_latest_gps
WHERE device_timestamp > NOW() - INTERVAL '1 day';
```

### Check GPS Data Growth:
```sql
-- Count GPS records
SELECT 
  COUNT(*) as total_records,
  COUNT(DISTINCT vehicle_id) as vehicles_tracked,
  MIN(timestamp) as oldest_record,
  MAX(timestamp) as latest_record
FROM gps_data;
```

### Clean Old Data (Run Monthly):
```sql
-- Delete GPS data older than 30 days
DELETE FROM gps_data 
WHERE timestamp < NOW() - INTERVAL '30 days';

-- See how many records deleted
-- (Check rows affected in result)
```

---

## 🚀 Add More Vehicles

To track more vehicles, repeat steps 2-3:

### For Each New GPS Device:

1. **Get vehicle UUID** from database
2. **Flash Arduino** with that UUID in `VEHICLE_UUID`
3. **Install in vehicle** 
4. **Verify** on live map

**Pro Tip**: Keep a table of your devices:

| Arduino Device | Vehicle UUID | Plate Number | Status |
|----------------|--------------|--------------|--------|
| ESP32-001 | 550e8400-... | ABC-1234 | ✅ Active |
| ESP32-002 | 6ba7b810-... | XYZ-5678 | 🔄 Pending |
| ESP32-003 | 6ba7b811-... | DEF-9012 | 🔄 Pending |

---

## 🎓 How It Works

```
┌──────────────────┐
│  Your Arduino    │
│  (ESP32 + GPS)   │
└────────┬─────────┘
         │ Sends every 30 seconds:
         │ {
         │   "lat": 14.599524,
         │   "long": 120.984219,
         │   "timestamp": "2025-11-16T12:00:00Z",
         │   "vehicle_id": "550e8400-..."
         │ }
         ↓
┌──────────────────┐
│   Supabase DB    │
│   gps_data       │  ← Stores all GPS points
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│ vehicle_latest_  │  ← View: Latest position
│     gps (view)   │     per vehicle
└────────┬─────────┘
         │
         ↓
┌──────────────────┐
│   LiveMap.vue    │  ← Your web interface
│  (Auto-refresh)  │     Shows markers on map
└──────────────────┘
```

---

## ✅ Success Checklist

- [ ] Ran `link-vehicle-to-gps.sql` in Supabase
- [ ] Updated `VEHICLE_UUID` in Arduino code
- [ ] Uploaded Arduino code
- [ ] Serial Monitor shows "HTTP 201"
- [ ] GPS data has `vehicle_id` in database
- [ ] `vehicle_latest_gps` view shows your vehicle
- [ ] Live Map shows vehicle marker
- [ ] Marker updates automatically

---

## 📞 Need Help?

### Quick SQL Checks:

```sql
-- 1. Check column exists
SELECT column_name FROM information_schema.columns 
WHERE table_name='gps_data' AND column_name='vehicle_id';

-- 2. Check recent GPS data
SELECT * FROM gps_data ORDER BY created_at DESC LIMIT 5;

-- 3. Check vehicle latest position
SELECT * FROM vehicle_latest_gps;

-- 4. Check route history (replace UUID)
SELECT * FROM get_vehicle_route(
  '550e8400-e29b-41d4-a716-446655440000', -- Your vehicle UUID
  24 -- hours
);
```

### Files You Updated:

✅ `link-vehicle-to-gps.sql` - Database migration  
✅ `ESP32_GPS_WIFI_SUPABASE_SPIFFS.ino` - Arduino code  
✅ `src/pages/LiveMap.vue` - Map interface (already updated)  
✅ `src/router/index.js` - Routes (already configured)  
✅ `src/pages/Navbar.vue` - Menu (already configured)  

---

**🎊 Congratulations! Your vehicle tracking is LIVE! 🗺️📍**

Drive safely and enjoy real-time GPS tracking! 🚗

