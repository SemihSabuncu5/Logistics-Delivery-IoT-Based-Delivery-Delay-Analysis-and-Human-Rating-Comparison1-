-- PostgreSQL / pgAdmin
-- Import data/processed/deliveries_cleaned.csv into public.deliveries_cleaned.
-- Create this table first, then use pgAdmin Import/Export Data (CSV, header on).

DROP TABLE IF EXISTS public.deliveries_cleaned;

CREATE TABLE public.deliveries_cleaned (
    delivery_id TEXT PRIMARY KEY,
    delivery_person_id TEXT,
    delivery_person_age NUMERIC(5,2),
    delivery_person_rating NUMERIC(3,2),
    restaurant_latitude NUMERIC(10,6),
    restaurant_longitude NUMERIC(10,6),
    delivery_latitude NUMERIC(10,6),
    delivery_longitude NUMERIC(10,6),
    order_date TEXT,
    time_ordered TEXT,
    time_order_picked TEXT,
    weather_conditions TEXT,
    road_traffic_density TEXT,
    vehicle_condition INTEGER,
    type_of_order TEXT,
    type_of_vehicle TEXT,
    multiple_deliveries NUMERIC(3,1),
    festival TEXT,
    city TEXT,
    time_taken_min INTEGER,
    order_datetime TIMESTAMP,
    pickup_datetime TIMESTAMP,
    order_to_pickup_min NUMERIC(10,2),
    straight_line_distance_km NUMERIC(10,3)
);
