-- =============================================================================
-- GPS Data Filter Trigger
-- =============================================================================
-- This trigger automatically prevents insertion of invalid GPS coordinates
-- (0, 0) or NULL values that would mess up the map trails.
--
-- HOW TO USE:
-- 1. Go to your Supabase Dashboard
-- 2. Navigate to SQL Editor
-- 3. Copy and paste this entire file
-- 4. Click "Run" to execute
--
-- WHAT IT DOES:
-- - Blocks GPS entries with lat=0 AND long=0 (invalid coordinates)
-- - Blocks GPS entries with NULL lat or NULL long
-- - Allows valid GPS coordinates to pass through normally
-- =============================================================================

-- Drop existing function and trigger if they exist (for re-runs)
DROP TRIGGER IF EXISTS filter_invalid_gps_trigger ON public.gps_data;
DROP FUNCTION IF EXISTS public.filter_invalid_gps_data();

-- Create the trigger function
CREATE OR REPLACE FUNCTION public.filter_invalid_gps_data()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Block if both latitude and longitude are 0 (invalid coordinates)
  IF NEW.lat = 0 AND NEW.long = 0 THEN
    RAISE NOTICE 'Blocked invalid GPS data: lat=0, long=0 for vehicle_id=%', NEW.vehicle_id;
    RETURN NULL; -- Skip this insert
  END IF;
  
  -- Block if latitude or longitude is NULL
  IF NEW.lat IS NULL OR NEW.long IS NULL THEN
    RAISE NOTICE 'Blocked GPS data with NULL coordinates for vehicle_id=%', NEW.vehicle_id;
    RETURN NULL; -- Skip this insert
  END IF;
  
  -- Optional: Block coordinates that are clearly invalid (outside valid ranges)
  -- Latitude must be between -90 and 90
  -- Longitude must be between -180 and 180
  IF NEW.lat < -90 OR NEW.lat > 90 OR NEW.long < -180 OR NEW.long > 180 THEN
    RAISE NOTICE 'Blocked GPS data with out-of-range coordinates: lat=%, long=% for vehicle_id=%', 
                 NEW.lat, NEW.long, NEW.vehicle_id;
    RETURN NULL; -- Skip this insert
  END IF;
  
  -- If all checks pass, allow the insert
  RETURN NEW;
END;
$$;

-- Create the trigger that fires BEFORE INSERT
CREATE TRIGGER filter_invalid_gps_trigger
  BEFORE INSERT ON public.gps_data
  FOR EACH ROW
  EXECUTE FUNCTION public.filter_invalid_gps_data();

-- Add a comment for documentation
COMMENT ON FUNCTION public.filter_invalid_gps_data() IS 
  'Automatically filters out invalid GPS coordinates (0,0), NULL values, and out-of-range coordinates before insertion';

-- =============================================================================
-- VERIFICATION
-- =============================================================================
-- After running this script, you can test it:
--
-- Test 1: Try to insert invalid data (should be blocked)
-- INSERT INTO gps_data (lat, long, vehicle_id, timestamp) 
-- VALUES (0, 0, 'your-vehicle-uuid', NOW());
--
-- Test 2: Try to insert valid data (should work)
-- INSERT INTO gps_data (lat, long, vehicle_id, timestamp) 
-- VALUES (14.5995, 120.9842, 'your-vehicle-uuid', NOW());
--
-- Check logs to see blocked attempts:
-- SELECT * FROM pg_stat_statements WHERE query LIKE '%filter_invalid_gps%';
-- =============================================================================

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✓ GPS filter trigger installed successfully!';
  RAISE NOTICE '✓ Invalid coordinates (0,0) will now be automatically blocked';
  RAISE NOTICE '✓ NULL coordinates will be automatically blocked';
  RAISE NOTICE '✓ Out-of-range coordinates will be automatically blocked';
END $$;

