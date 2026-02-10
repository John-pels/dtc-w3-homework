-- Module 3 Homework: BigQuery Setup Scripts
-- Replace 'your-bucket-name' with your actual GCS bucket name

-- ============================================
-- STEP 1: Create External Table
-- ============================================
CREATE OR REPLACE EXTERNAL TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://your-bucket-name/yellow_tripdata_2024-*.parquet']
);

-- ============================================
-- STEP 2: Create Materialized Table
-- ============================================
CREATE OR REPLACE TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized` AS
SELECT * FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`;

-- ============================================
-- STEP 3: Create Partitioned and Clustered Table (for Question 5)
-- ============================================
CREATE OR REPLACE TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;

-- ============================================
-- Verify Tables Created Successfully
-- ============================================
-- Check external table
SELECT COUNT(*) as external_count 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`;

-- Check materialized table
SELECT COUNT(*) as materialized_count 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;

-- Check partitioned/clustered table
SELECT COUNT(*) as partitioned_count 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_partitioned_clustered`;
