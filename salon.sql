-- Schema and seed data for My Salon
-- Run with: psql -U freecodecamp -d salon -f salon.sql

-- Tables
CREATE TABLE IF NOT EXISTS customers (
  customer_id SERIAL PRIMARY KEY,
  phone VARCHAR UNIQUE,
  name VARCHAR
);

CREATE TABLE IF NOT EXISTS services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE IF NOT EXISTS appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(customer_id),
  service_id INT REFERENCES services(service_id),
  time VARCHAR
);

-- Seed services (ensure id 1 exists and is 'cut')
INSERT INTO services(name)
SELECT s FROM (VALUES ('cut'), ('color'), ('perm'), ('style'), ('trim')) AS v(s)
WHERE NOT EXISTS (SELECT 1 FROM services);
