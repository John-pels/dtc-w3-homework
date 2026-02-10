-- Module 3 Homework: All SQL Queries
-- Project: dtc-w3-homework | Dataset: yellow_tripdata

-- ============================================
-- Question 1: Counting Records
-- ============================================
-- What is count of records for the 2024 Yellow Taxi Data?
SELECT COUNT(*) AS total_records
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
-- Answer: 20,332,093


-- ============================================
-- Question 2: Data Read Estimation
-- ============================================
-- Count distinct PULocationIDs on External Table
SELECT COUNT(DISTINCT PULocationID) AS distinct_pu_locations
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`;
-- Estimated bytes: 0 MB (external table)

-- Count distinct PULocationIDs on Materialized Table
SELECT COUNT(DISTINCT PULocationID) AS distinct_pu_locations
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
-- Estimated bytes: 155.12 MB (materialized table)
-- Answer: 0 MB for the External Table and 155.12 MB for the Materialized Table


-- ============================================
-- Question 3: Understanding Columnar Storage
-- ============================================
-- Query 1: Single column
SELECT PULocationID 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
-- Estimated bytes: ~77 MB

-- Query 2: Two columns
SELECT PULocationID, DOLocationID 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
-- Estimated bytes: ~155 MB (approximately double)
-- Answer: BigQuery is columnar, so it only scans requested columns


-- ============================================
-- Question 4: Counting Zero Fare Trips
-- ============================================
-- How many records have a fare_amount of 0?
SELECT COUNT(*) AS zero_fare_trips
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`
WHERE fare_amount = 0;
-- Answer: 128,210


-- ============================================
-- Question 5: Partitioning and Clustering
-- ============================================
-- Best strategy: Partition by tpep_dropoff_datetime and Cluster on VendorID
-- (See setup.sql for table creation)
-- Answer: Partition by tpep_dropoff_datetime and Cluster on VendorID


-- ============================================
-- Question 6: Partition Benefits
-- ============================================
-- Query on non-partitioned table
SELECT DISTINCT VendorID
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
-- Estimated bytes: 310.24 MB

-- Query on partitioned table
SELECT DISTINCT VendorID
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_partitioned_clustered`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
-- Estimated bytes: 26.84 MB
-- Answer: 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table


-- ============================================
-- Question 7: External Table Storage
-- ============================================
-- Where is the data stored in the External Table?
-- Answer: GCP Bucket (Google Cloud Storage)


-- ============================================
-- Question 8: Clustering Best Practices
-- ============================================
-- Is it best practice to always cluster your data?
-- Answer: False
-- Clustering is beneficial for specific use cases but not always necessary


-- ============================================
-- Question 9: Understanding Table Scans
-- ============================================
-- SELECT count(*) from materialized table
SELECT COUNT(*) 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
-- Estimated bytes: 0 MB
-- Explanation: BigQuery uses metadata to return count without scanning data


-- ============================================
-- Additional Useful Queries
-- ============================================

-- View table schema
SELECT column_name, data_type
FROM `dtc-w3-homework.yellow_tripdata.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'yellow_taxi_materialized';

-- Check table size
SELECT 
  table_name,
  ROUND(size_bytes/POW(10,9), 2) AS size_gb,
  row_count
FROM `dtc-w3-homework.yellow_tripdata.__TABLES__`
WHERE table_id IN ('yellow_taxi_external', 'yellow_taxi_materialized', 'yellow_taxi_partitioned_clustered');

-- Sample data from materialized table
SELECT *
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`
LIMIT 10;

-- Check partition information
SELECT
  partition_id,
  total_rows,
  ROUND(total_logical_bytes/POW(10,6), 2) AS size_mb
FROM `dtc-w3-homework.yellow_tripdata.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_taxi_partitioned_clustered'
ORDER BY partition_id;
