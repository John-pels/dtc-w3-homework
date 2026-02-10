-- Module 3 Homework: BigQuery Setup Scripts
-- Replace 'your-project', 'your_dataset', and 'your-bucket-name' with your actual values

-- ============================================
-- STEP 1: Create External Table
-- ============================================
CREATE OR REPLACE EXTERNAL TABLE `your-project.your_dataset.yellow_taxi_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://your-bucket-name/yellow_tripdata_2024-*.parquet']
);

-- ============================================
-- STEP 2: Create Materialized Table
-- ============================================
CREATE OR REPLACE TABLE `your-project.your_dataset.yellow_taxi_materialized` AS
SELECT * FROM `your-project.your_dataset.yellow_taxi_external`;

-- ============================================
-- STEP 3: Create Partitioned and Clustered Table (for Question 5)
-- ============================================
CREATE OR REPLACE TABLE `your-project.your_dataset.yellow_taxi_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `your-project.your_dataset.yellow_taxi_materialized`;

-- ============================================
-- Verify Tables Created Successfully
-- ============================================
-- Check external table
SELECT COUNT(*) as external_count 
FROM `your-project.your_dataset.yellow_taxi_external`;

-- Check materialized table
SELECT COUNT(*) as materialized_count 
FROM `your-project.your_dataset.yellow_taxi_materialized`;

-- Check partitioned/clustered table
SELECT COUNT(*) as partitioned_count 
FROM `your-project.your_dataset.yellow_taxi_partitioned_clustered`;
