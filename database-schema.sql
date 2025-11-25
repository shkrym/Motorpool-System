-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.drivers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  employee_id text NOT NULL UNIQUE,
  full_name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text,
  license_number text,
  license_expiry date,
  position text DEFAULT 'Driver'::text,
  department text,
  is_active boolean DEFAULT true,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT drivers_pkey PRIMARY KEY (id),
  CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.fuel_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vehicle_id uuid NOT NULL,
  trip_id uuid,
  driver_id uuid,
  liters numeric NOT NULL CHECK (liters > 0::numeric),
  cost numeric CHECK (cost >= 0::numeric),
  odometer numeric,
  station text,
  trip_reference text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT fuel_logs_pkey PRIMARY KEY (id),
  CONSTRAINT fuel_logs_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id),
  CONSTRAINT fuel_logs_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id),
  CONSTRAINT fuel_logs_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id)
);
CREATE TABLE public.gps_data (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  lat double precision,
  long double precision,
  timestamp timestamp with time zone,
  vehicle_id uuid,
  is_queued boolean DEFAULT false,
  CONSTRAINT gps_data_pkey PRIMARY KEY (id),
  CONSTRAINT gps_data_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id)
);
CREATE TABLE public.maintenance (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vehicle_id uuid NOT NULL,
  service_type text NOT NULL,
  last_service_date date NOT NULL,
  next_due_date date NOT NULL,
  interval_days integer NOT NULL CHECK (interval_days > 0),
  estimated_cost numeric DEFAULT 0 CHECK (estimated_cost >= 0::numeric),
  status text DEFAULT 'up-to-date'::text CHECK (status = ANY (ARRAY['up-to-date'::text, 'due-soon'::text, 'overdue'::text, 'completed'::text])),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT maintenance_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id)
);
CREATE TABLE public.maintenance_records (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vehicle_id uuid NOT NULL,
  type text NOT NULL,
  description text,
  cost numeric CHECK (cost >= 0::numeric),
  performed_by text,
  performed_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT maintenance_records_pkey PRIMARY KEY (id),
  CONSTRAINT maintenance_records_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  employee_id text NOT NULL UNIQUE,
  full_name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text,
  license_number text,
  license_expiry date,
  position text DEFAULT 'Staff'::text,
  department text,
  role text NOT NULL DEFAULT 'staff'::text CHECK (role = ANY (ARRAY['admin'::text, 'driver'::text, 'staff'::text])),
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.trips (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  trip_id text NOT NULL UNIQUE,
  vehicle_id uuid NOT NULL,
  driver_id uuid,
  origin text,
  destination text NOT NULL,
  purpose text,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text])),
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  expected_end_time timestamp with time zone,
  actual_start_time timestamp with time zone,
  actual_end_time timestamp with time zone,
  passenger_name text,
  passenger_count integer CHECK (passenger_count >= 0),
  passenger_department text,
  start_odometer numeric,
  end_odometer numeric,
  distance_km numeric,
  notes text,
  cancellation_reason text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trips_pkey PRIMARY KEY (id),
  CONSTRAINT trips_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id),
  CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id)
);
CREATE TABLE public.vehicles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vehicle_id text NOT NULL UNIQUE,
  plate_number text NOT NULL UNIQUE,
  year integer NOT NULL CHECK (year >= 1990 AND year <= 2030),
  vehicle_type text NOT NULL CHECK (vehicle_type = ANY (ARRAY['car'::text, 'van'::text, 'utility vehicles'::text, 'minibus'::text, 'truck'::text, 'suv'::text, 'motorcycle'::text, 'bus'::text])),
  make text,
  model text,
  status text NOT NULL DEFAULT 'available'::text CHECK (status = ANY (ARRAY['available'::text, 'in_use'::text, 'maintenance'::text, 'out_of_service'::text])),
  assigned_driver_code text,
  assigned_driver_id uuid,
  assigned_department text,
  odometer_reading numeric DEFAULT 0,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vehicles_pkey PRIMARY KEY (id),
  CONSTRAINT vehicles_assigned_driver_id_fkey FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id)
);