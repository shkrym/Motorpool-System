-- =====================================================
-- MOTORPOOL SYSTEM - COMPLETE DATABASE SCHEMA
-- =====================================================
-- This schema is designed for Supabase PostgreSQL
-- Generated to match motorpool-V2 project requirements
-- ⚠️ WARNING: THIS WILL DROP ALL EXISTING TABLES AND DATA
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- DROP EXISTING TABLES (IN CORRECT ORDER)
-- =====================================================
DROP TABLE IF EXISTS maintenance_records CASCADE;
DROP TABLE IF EXISTS maintenance CASCADE;
DROP TABLE IF EXISTS fuel_logs CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Drop existing views
DROP VIEW IF EXISTS vehicle_status_summary CASCADE;
DROP VIEW IF EXISTS monthly_fuel_consumption CASCADE;
DROP VIEW IF EXISTS vehicle_trip_history CASCADE;

-- =====================================================
-- 1. PROFILES TABLE (Users, Drivers, Admins)
-- =====================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    employee_id TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    license_number TEXT,
    license_expiry DATE,
    position TEXT DEFAULT 'Staff',
    department TEXT,
    role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('admin', 'driver', 'staff')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_employee_id ON profiles(employee_id);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON profiles(is_active);

-- =====================================================
-- 2. VEHICLES TABLE (Fleet Management)
-- =====================================================
CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id TEXT UNIQUE NOT NULL,
    plate_number TEXT UNIQUE NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 1990 AND year <= 2030),
    vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('car', 'van', 'utility vehicles', 'minibus', 'truck', 'suv', 'motorcycle', 'bus')),
    make TEXT,
    model TEXT,
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'in_use', 'maintenance', 'out_of_service')),
    assigned_driver_code TEXT,
    assigned_driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    assigned_department TEXT,
    odometer_reading NUMERIC(10, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_type ON vehicles(vehicle_type);
CREATE INDEX IF NOT EXISTS idx_vehicles_driver_id ON vehicles(assigned_driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_plate ON vehicles(plate_number);

-- =====================================================
-- 3. TRIPS TABLE (Trip Management)
-- =====================================================
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id TEXT UNIQUE NOT NULL,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    origin TEXT,
    destination TEXT NOT NULL,
    purpose TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'in_progress', 'completed', 'cancelled')),
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    expected_end_time TIMESTAMP WITH TIME ZONE,
    actual_start_time TIMESTAMP WITH TIME ZONE,
    actual_end_time TIMESTAMP WITH TIME ZONE,
    passenger_name TEXT,
    passenger_count INTEGER CHECK (passenger_count >= 0),
    passenger_department TEXT,
    start_odometer NUMERIC(10, 2),
    end_odometer NUMERIC(10, 2),
    distance_km NUMERIC(10, 2),
    notes TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_trips_driver_id ON trips(driver_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_start_time ON trips(start_time);
CREATE INDEX IF NOT EXISTS idx_trips_created_at ON trips(created_at DESC);

-- =====================================================
-- 4. FUEL LOGS TABLE (Fuel Tracking)
-- =====================================================
CREATE TABLE fuel_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trips(id) ON DELETE SET NULL,
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    liters NUMERIC(10, 2) NOT NULL CHECK (liters > 0),
    cost NUMERIC(10, 2) CHECK (cost >= 0),
    odometer NUMERIC(10, 2),
    station TEXT,
    trip_reference TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_fuel_logs_vehicle_id ON fuel_logs(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_fuel_logs_trip_id ON fuel_logs(trip_id);
CREATE INDEX IF NOT EXISTS idx_fuel_logs_driver_id ON fuel_logs(driver_id);
CREATE INDEX IF NOT EXISTS idx_fuel_logs_created_at ON fuel_logs(created_at DESC);

-- =====================================================
-- 5. MAINTENANCE TABLE (Maintenance Schedules)
-- =====================================================
CREATE TABLE maintenance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    service_type TEXT NOT NULL,
    last_service_date DATE NOT NULL,
    next_due_date DATE NOT NULL,
    interval_days INTEGER NOT NULL CHECK (interval_days > 0),
    estimated_cost NUMERIC(10, 2) DEFAULT 0 CHECK (estimated_cost >= 0),
    status TEXT DEFAULT 'up-to-date' CHECK (status IN ('up-to-date', 'due-soon', 'overdue', 'completed')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_maintenance_vehicle_id ON maintenance(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_next_due_date ON maintenance(next_due_date);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance(status);

-- =====================================================
-- 6. MAINTENANCE RECORDS TABLE (Historical Records)
-- =====================================================
CREATE TABLE maintenance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    description TEXT,
    cost NUMERIC(10, 2) CHECK (cost >= 0),
    performed_by TEXT,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_maintenance_records_vehicle_id ON maintenance_records(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_records_performed_at ON maintenance_records(performed_at DESC);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to profiles
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to vehicles
DROP TRIGGER IF EXISTS update_vehicles_updated_at ON vehicles;
CREATE TRIGGER update_vehicles_updated_at
    BEFORE UPDATE ON vehicles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to trips
DROP TRIGGER IF EXISTS update_trips_updated_at ON trips;
CREATE TRIGGER update_trips_updated_at
    BEFORE UPDATE ON trips
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to maintenance
DROP TRIGGER IF EXISTS update_maintenance_updated_at ON maintenance;
CREATE TRIGGER update_maintenance_updated_at
    BEFORE UPDATE ON maintenance
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCTION: Auto-update maintenance status
-- =====================================================
CREATE OR REPLACE FUNCTION update_maintenance_status()
RETURNS void AS $$
BEGIN
    UPDATE maintenance
    SET status = CASE
        WHEN next_due_date < CURRENT_DATE THEN 'overdue'
        WHEN next_due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'due-soon'
        ELSE 'up-to-date'
    END
    WHERE status != 'completed';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE fuel_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_records ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROFILES POLICIES (FIXED - No Recursion)
-- =====================================================

-- Allow all authenticated users to read all profiles
-- (This avoids recursion and is needed for driver lookups)
CREATE POLICY "Allow authenticated users to read profiles"
    ON profiles FOR SELECT
    TO authenticated
    USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Allow authenticated users to insert profiles
-- (You can add admin check via application logic or triggers)
CREATE POLICY "Allow authenticated insert profiles"
    ON profiles FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Allow authenticated users to update profiles
-- (You can add admin check via application logic)
CREATE POLICY "Allow authenticated update profiles"
    ON profiles FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Allow authenticated users to delete profiles
-- (You can add admin check via application logic)
CREATE POLICY "Allow authenticated delete profiles"
    ON profiles FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- VEHICLES POLICIES (SIMPLIFIED)
-- =====================================================

-- Everyone authenticated can view vehicles
CREATE POLICY "Authenticated users can view vehicles"
    ON vehicles FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can insert vehicles
CREATE POLICY "Authenticated users can insert vehicles"
    ON vehicles FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Authenticated users can update vehicles
CREATE POLICY "Authenticated users can update vehicles"
    ON vehicles FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Authenticated users can delete vehicles
CREATE POLICY "Authenticated users can delete vehicles"
    ON vehicles FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- TRIPS POLICIES (SIMPLIFIED)
-- =====================================================

-- Everyone authenticated can view trips
CREATE POLICY "Authenticated users can view trips"
    ON trips FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can insert trips
CREATE POLICY "Authenticated users can insert trips"
    ON trips FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Authenticated users can update trips
CREATE POLICY "Authenticated users can update trips"
    ON trips FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Authenticated users can delete trips
CREATE POLICY "Authenticated users can delete trips"
    ON trips FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- FUEL LOGS POLICIES (SIMPLIFIED)
-- =====================================================

-- Everyone authenticated can view fuel logs
CREATE POLICY "Authenticated users can view fuel logs"
    ON fuel_logs FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can insert fuel logs
CREATE POLICY "Authenticated users can insert fuel logs"
    ON fuel_logs FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Authenticated users can update fuel logs
CREATE POLICY "Authenticated users can update fuel logs"
    ON fuel_logs FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Authenticated users can delete fuel logs
CREATE POLICY "Authenticated users can delete fuel logs"
    ON fuel_logs FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- MAINTENANCE POLICIES (SIMPLIFIED)
-- =====================================================

-- Everyone authenticated can view maintenance
CREATE POLICY "Authenticated users can view maintenance"
    ON maintenance FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can insert maintenance
CREATE POLICY "Authenticated users can insert maintenance"
    ON maintenance FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Authenticated users can update maintenance
CREATE POLICY "Authenticated users can update maintenance"
    ON maintenance FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Authenticated users can delete maintenance
CREATE POLICY "Authenticated users can delete maintenance"
    ON maintenance FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- MAINTENANCE RECORDS POLICIES (SIMPLIFIED)
-- =====================================================

-- Everyone authenticated can view maintenance records
CREATE POLICY "Authenticated users can view maintenance records"
    ON maintenance_records FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can insert maintenance records
CREATE POLICY "Authenticated users can insert maintenance records"
    ON maintenance_records FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Authenticated users can update maintenance records
CREATE POLICY "Authenticated users can update maintenance records"
    ON maintenance_records FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Authenticated users can delete maintenance records
CREATE POLICY "Authenticated users can delete maintenance records"
    ON maintenance_records FOR DELETE
    TO authenticated
    USING (true);

-- =====================================================
-- INITIAL DATA / SAMPLE DATA (OPTIONAL)
-- =====================================================
-- Uncomment to insert sample data for testing

/*
-- Sample Admin User (requires manual auth.users entry first)
INSERT INTO profiles (id, employee_id, full_name, email, role, position, department, is_active)
VALUES 
    ('your-auth-user-id-here', 'ADM-001', 'Admin User', 'admin@motorpool.com', 'admin', 'System Administrator', 'IT', true);

-- Sample Vehicles
INSERT INTO vehicles (vehicle_id, plate_number, year, vehicle_type, make, model, status)
VALUES 
    ('MP-001', 'ABC-1234', 2020, 'car', 'Toyota', 'Camry', 'available'),
    ('MP-002', 'XYZ-5678', 2019, 'van', 'Ford', 'Transit', 'available'),
    ('MP-003', 'DEF-9012', 2021, 'utility vehicles', 'Nissan', 'Navara', 'maintenance');
*/

-- =====================================================
-- VIEWS FOR REPORTING (OPTIONAL)
-- =====================================================

-- View: Vehicle Status Summary
CREATE OR REPLACE VIEW vehicle_status_summary AS
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM vehicles
GROUP BY status;

-- View: Monthly Fuel Consumption
CREATE OR REPLACE VIEW monthly_fuel_consumption AS
SELECT 
    DATE_TRUNC('month', created_at) as month,
    COUNT(*) as total_logs,
    SUM(liters) as total_liters,
    SUM(cost) as total_cost,
    ROUND(AVG(cost / NULLIF(liters, 0)), 2) as avg_cost_per_liter
FROM fuel_logs
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- View: Vehicle Trip History
CREATE OR REPLACE VIEW vehicle_trip_history AS
SELECT 
    v.vehicle_id,
    v.plate_number,
    t.trip_id,
    t.destination,
    t.status,
    t.distance_km,
    t.start_time,
    t.end_time,
    p.full_name as driver_name
FROM trips t
JOIN vehicles v ON t.vehicle_id = v.id
LEFT JOIN drivers p ON t.driver_id = p.id
ORDER BY t.created_at DESC;

-- =====================================================
-- COMPLETED!
-- =====================================================
-- Schema created successfully for Motorpool System V2
-- Tables: profiles, vehicles, trips, fuel_logs, maintenance, maintenance_records
-- Includes: Indexes, Triggers, RLS Policies, Views
-- =====================================================

