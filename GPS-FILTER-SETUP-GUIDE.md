# 🛡️ GPS Data Filter & Cleanup Guide

## Overview

This guide shows you how to automatically prevent and clean up invalid GPS coordinates (0, 0) that mess up your map trails.

## 📋 What You'll Get

✅ **Automatic Protection**: New invalid GPS data (0, 0) will be blocked before entering the database  
✅ **Clean Database**: Remove all existing invalid GPS entries  
✅ **Better Map Trails**: No more broken trails caused by zero coordinates  
✅ **Range Validation**: Also blocks coordinates outside valid Earth ranges  

---

## 🚀 Quick Setup (2 Steps)

### Step 1: Install the GPS Filter Trigger

This prevents **future** invalid data from being inserted.

1. Go to your **Supabase Dashboard** → https://supabase.com/dashboard
2. Select your project
3. Click **SQL Editor** (in the left sidebar)
4. Click **New Query**
5. Open the file: `supabase-trigger-filter-invalid-gps.sql`
6. Copy **ALL** the contents
7. Paste into the SQL Editor
8. Click **Run** (or press `Ctrl + Enter`)

✅ You should see success messages confirming the trigger is installed!

### Step 2: Clean Up Existing Invalid Data

This removes **existing** invalid GPS data already in your database.

1. Still in **SQL Editor**, create another **New Query**
2. Open the file: `supabase-cleanup-invalid-gps.sql`
3. Copy **ALL** the contents
4. Paste into the SQL Editor
5. Click **Run**

✅ You'll see a summary of how many invalid records were removed!

---

## 📊 What Gets Blocked/Removed

The filter will block/remove GPS entries with:

| Condition | Example | Why It's Invalid |
|-----------|---------|------------------|
| **Zero coordinates** | `lat=0, long=0` | This is null island in the ocean, not a real location |
| **NULL values** | `lat=NULL` or `long=NULL` | Missing coordinate data |
| **Out of range latitude** | `lat=100` or `lat=-200` | Valid latitude is -90 to 90 |
| **Out of range longitude** | `long=200` or `long=-300` | Valid longitude is -180 to 180 |

---

## 🧪 Testing the Filter

After installation, you can test that it's working:

### Test 1: Try to Insert Invalid Data (Should Be Blocked)

```sql
-- This should be blocked by the trigger
INSERT INTO gps_data (lat, long, vehicle_id, timestamp) 
VALUES (0, 0, 'your-vehicle-uuid-here', NOW());
```

Expected result: **0 rows inserted** (blocked silently)

### Test 2: Try to Insert Valid Data (Should Work)

```sql
-- This should work fine (Manila coordinates)
INSERT INTO gps_data (lat, long, vehicle_id, timestamp) 
VALUES (14.5995, 120.9842, 'your-vehicle-uuid-here', NOW());
```

Expected result: **1 row inserted** ✅

### Test 3: Verify No Invalid Data Exists

```sql
-- Check for zero coordinates (should return 0)
SELECT COUNT(*) FROM gps_data WHERE lat = 0 AND long = 0;

-- Check for NULL coordinates (should return 0)
SELECT COUNT(*) FROM gps_data WHERE lat IS NULL OR long IS NULL;
```

---

## 📁 Files Included

1. **`supabase-trigger-filter-invalid-gps.sql`**  
   - Creates the automatic filter trigger
   - Runs on every GPS insert
   - Blocks invalid coordinates

2. **`supabase-cleanup-invalid-gps.sql`**  
   - One-time cleanup script
   - Removes existing invalid data
   - Shows cleanup summary

3. **`GPS-FILTER-SETUP-GUIDE.md`** (this file)  
   - Setup instructions
   - Testing guide
   - Troubleshooting tips

---

## ⚙️ How It Works

### The Trigger Function

```
ESP32 GPS Device
      ↓
   Sends GPS data (lat, long)
      ↓
   Supabase Database
      ↓
   BEFORE INSERT TRIGGER checks:
      - Is lat = 0 AND long = 0? → BLOCK ❌
      - Is lat or long NULL? → BLOCK ❌
      - Is lat/long out of range? → BLOCK ❌
      - Valid coordinates? → ALLOW ✅
      ↓
   Stored in gps_data table
```

### Benefits

- **Zero maintenance**: Works automatically
- **No app changes needed**: Filter runs at database level
- **Performance**: Minimal overhead (runs in microseconds)
- **Clean data**: Only valid GPS coordinates stored

---

## 🔍 Monitoring

### Check How Many Records Were Blocked Today

```sql
-- Note: Blocked records are not stored, but you can check logs
SELECT 
  COUNT(*) as valid_records_today,
  MIN(timestamp) as first_record,
  MAX(timestamp) as last_record
FROM gps_data 
WHERE timestamp >= CURRENT_DATE;
```

### View GPS Data Quality

```sql
SELECT 
  vehicle_id,
  COUNT(*) as total_gps_points,
  MIN(lat) as min_latitude,
  MAX(lat) as max_latitude,
  MIN(long) as min_longitude,
  MAX(long) as max_longitude
FROM gps_data
GROUP BY vehicle_id
ORDER BY total_gps_points DESC;
```

---

## 🛠️ Troubleshooting

### Problem: Trigger doesn't seem to be working

**Solution**: Check if trigger exists:

```sql
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'filter_invalid_gps_trigger';
```

If not found, re-run Step 1.

### Problem: Still seeing (0, 0) coordinates

**Solution**: 
1. Make sure you ran **both** scripts (trigger + cleanup)
2. Check when the data was inserted:
   ```sql
   SELECT * FROM gps_data 
   WHERE lat = 0 AND long = 0 
   ORDER BY timestamp DESC;
   ```
3. If old data, run the cleanup script again
4. If new data, check your ESP32 code

### Problem: Want to disable the filter temporarily

**Solution**: Drop the trigger (can be re-added later):

```sql
DROP TRIGGER IF EXISTS filter_invalid_gps_trigger ON public.gps_data;
```

To re-enable, just run Step 1 again.

---

## 📱 Your ESP32 Code

The filter works regardless of your ESP32 code, but you can also add validation on the device:

```cpp
// In your ESP32 code, before sending:
if (latitude == 0.0 && longitude == 0.0) {
  Serial.println("⚠️ Invalid GPS (0,0) - skipping");
  return; // Don't send to Supabase
}

if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
  Serial.println("⚠️ GPS out of range - skipping");
  return;
}

// Valid coordinates, send to Supabase
sendToSupabase(latitude, longitude);
```

This provides **double protection** (device + database)!

---

## ✨ Summary

| What | When | Result |
|------|------|--------|
| **Trigger** | Every GPS insert | Blocks invalid data automatically |
| **Cleanup** | One-time (or as needed) | Removes existing invalid data |
| **Your App** | After setup | Clean trails, no (0,0) coordinates |

---

## 🎉 Done!

Your GPS tracking system now automatically filters out invalid coordinates. Your map trails will be clean and accurate! 

If you have any questions or issues, check the troubleshooting section above.

**Happy tracking! 🚗📍**

