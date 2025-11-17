# 🗺️ GPS Trail & History Features

## Trail Point Limits

### Live Trail (2 Hours)
- **Max Points:** 240 GPS points
- **Time Window:** Last 2 hours
- **Calculation:** 2 hours × 60 minutes × 2 points/minute = 240 points
- **Update Interval:** ESP32 uploads every 30 seconds
- **Display:** Blue/green polyline with breadcrumb circles

### How It Works:
```javascript
// In LiveMap.vue
const TRAIL_POINT_LIMIT = 240  // 2 hours of GPS data

// Query filters to last 2 hours
const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()

// Limits to 240 most recent points
.limit(240)
```

---

## 24-Hour Route History Features

### Feature 1: 24H Trail Display on Map 🆕
Click **"Show 24H Trail"** button (purple) in map controls:

### Features:
✅ **Purple dashed line** - Shows full 24-hour route on map  
✅ **Up to 2,880 GPS points** - Complete day's movement  
✅ **Reduced breadcrumbs** - Shows every 10th point to reduce clutter  
✅ **Toggle on/off** - Works alongside 2-hour live trail  
✅ **Different style** - Purple color, dashed line, smaller circles  

### Feature 2: 24H History Modal
Click **"View Route History (24H)"** on vehicle info panel:

### Features:
✅ **Summary stats** - Total points, duration, latest update  
✅ **Timeline view** - Chronological list of all GPS coordinates  
✅ **Click to view** - Focus map on any point in history  
✅ **Temporary marker** - Shows selected point for 5 seconds  

### Max Points (24H):
- **Max Points:** 2,880 GPS points
- **Time Window:** Last 24 hours
- **Calculation:** 24 hours × 60 minutes × 2 points/minute = 2,880 points

---

## Database Storage

### Automatic Cleanup (Recommended):

To prevent unlimited growth, add this to your database:

```sql
-- Option 1: Delete GPS data older than 7 days (recommended)
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
    'delete-old-gps-data',
    '0 2 * * *',  -- Run at 2 AM daily
    $$DELETE FROM gps_data WHERE timestamp < NOW() - INTERVAL '7 days'$$
);

-- Option 2: Manual cleanup (run monthly)
DELETE FROM gps_data 
WHERE timestamp < NOW() - INTERVAL '30 days';
```

### Current Storage:
- **Live trail:** Shows last 240 points (2 hours)
- **24H history:** Shows last 2,880 points (24 hours)
- **Database:** Stores ALL points (grows indefinitely unless cleaned)

---

## What Gets Displayed

### Live Map View:
```
📍 Current location marker

🔵 2-Hour Live Trail (Blue, solid):
   └─ Last 240 GPS points
   └─ Solid blue line
   └─ Breadcrumb circles (every point)
   └─ Hover for timestamp

🟣 24-Hour Trail (Purple, dashed):
   └─ Last 2,880 GPS points
   └─ Purple dashed line
   └─ Breadcrumb circles (every 10th point)
   └─ Smaller, more transparent
```

### Controls:
```
🟢 Center All - Fit all vehicles in view
🔵 2H Trail - Toggle 2-hour live trail
🟣 24H Trail - Toggle 24-hour historical trail
```

### 24-Hour History Modal:
```
📊 Summary: Total points, duration, latest update
📜 Timeline: All GPS points in last 24 hours
🎯 Click any point to view on map
```

---

## Performance

### Live Trail (240 points):
- ✅ Fast rendering
- ✅ Smooth updates
- ✅ No lag

### 24-Hour History (2,880 points):
- ✅ Modal view (doesn't slow map)
- ✅ Scrollable timeline
- ✅ On-demand loading

---

## Example Timeline

### With 30-second intervals:

| Time Range | Points | Display |
|------------|--------|---------|
| Last 2 hours | 240 | Live trail on map |
| Last 24 hours | 2,880 | History modal |
| Last 7 days | 20,160 | Database only |
| Last 30 days | 86,400 | Database (cleanup recommended) |

---

## User Actions

### View Live Trail:
1. Map automatically shows last 2 hours (240 points)
2. Updates every 30 seconds with new GPS data
3. Old points beyond 2 hours are hidden

### View 24-Hour History:
1. Click on a vehicle
2. Click **"View Route History (24H)"** button
3. See full timeline with all GPS points
4. Click any point to view on map

---

## Tips

### For Best Performance:
- ✅ Keep live trail at 240 points (current setting)
- ✅ Use 24H history for detailed analysis
- ✅ Clean up database monthly (delete old data)

### Storage Estimates:
```
1 GPS point = ~50 bytes
240 points (2h) = 12 KB
2,880 points (24h) = 144 KB
20,160 points (7d) = 1 MB
```

Small enough to keep 7-30 days of history without issues!

---

**Your GPS tracking now has smart limits and powerful history viewing!** 🎉

