# Module 3 Homework: Data Warehousing & BigQuery

## Overview
This repository contains solutions to the Module 3 homework assignment focusing on BigQuery and Google Cloud Storage operations using the Yellow Taxi Trip Records for January 2024 - June 2024.

## Dataset
**Source**: NYC Yellow Taxi Trip Records (January 2024 - June 2024)  
**Format**: Parquet files  
**Link**: [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

## Setup Instructions

### 1. Load Data to GCS
Upload the 6 parquet files (January - June 2024) to your GCS bucket using the provided script or manually.

### 2. Create External Table
```sql
CREATE OR REPLACE EXTERNAL TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://your-bucket-name/yellow_tripdata_2024-*.parquet']
);
```

### 3. Create Materialized Table
```sql
CREATE OR REPLACE TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized` AS
SELECT * FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`;
```

---

## Solutions

### Question 1: Counting Records
**Question**: What is count of records for the 2024 Yellow Taxi Data?

**SQL Query**:
```sql
SELECT COUNT(*) AS total_records
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
```

**Answer**: **20,332,093**

---

### Question 2: Data Read Estimation
**Question**: What is the estimated amount of data that will be read when counting distinct PULocationIDs on the External Table vs the Materialized Table?

**SQL Queries**:
```sql
-- External Table
SELECT COUNT(DISTINCT PULocationID) 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_external`;

-- Materialized Table
SELECT COUNT(DISTINCT PULocationID) 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
```

**Answer**: **0 MB for the External Table and 155.12 MB for the Materialized Table**

**Explanation**: 
- External tables don't show estimated bytes in BigQuery UI because the data resides in GCS
- Materialized tables show the actual data size that will be scanned in BigQuery storage

---

### Question 3: Understanding Columnar Storage
**Question**: Why are the estimated number of bytes different when querying one column vs two columns?

**SQL Queries**:
```sql
-- Query 1: Single column
SELECT PULocationID 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;

-- Query 2: Two columns
SELECT PULocationID, DOLocationID 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
```

**Answer**: **BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed.**

**Explanation**: 
BigQuery stores data in a columnar format, meaning each column is stored separately. When you query specific columns, BigQuery only reads those columns from storage, not the entire row. This is a key advantage of columnar databases for analytical workloads.

---

### Question 4: Counting Zero Fare Trips
**Question**: How many records have a fare_amount of 0?

**SQL Query**:
```sql
SELECT COUNT(*) AS zero_fare_trips
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`
WHERE fare_amount = 0;
```

**Answer**: **128,210**

---

### Question 5: Partitioning and Clustering Strategy
**Question**: What is the best strategy to optimize a table if queries always filter on tpep_dropoff_datetime and order by VendorID?

**SQL Query**:
```sql
CREATE OR REPLACE TABLE `dtc-w3-homework.yellow_tripdata.yellow_taxi_partitioned_clustered`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
```

**Answer**: **Partition by tpep_dropoff_datetime and Cluster on VendorID**

**Explanation**:
- **Partition** by the filter column (tpep_dropoff_datetime) to reduce data scanned
- **Cluster** by the ordering column (VendorID) to improve query performance
- Partitioning comes first as it provides the most significant performance improvement for filtering
- Clustering further optimizes queries within each partition

---

### Question 6: Partition Benefits
**Question**: What are the estimated bytes for querying distinct VendorIDs between 2024-03-01 and 2024-03-15 on non-partitioned vs partitioned tables?

**SQL Queries**:
```sql
-- Non-partitioned table
SELECT DISTINCT VendorID
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

-- Partitioned table
SELECT DISTINCT VendorID
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_partitioned_clustered`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';
```

**Answer**: **310.24 MB for non-partitioned table and 26.84 MB for the partitioned table**

**Explanation**: 
The partitioned table only scans the partitions for March 1-15, while the non-partitioned table must scan all 6 months of data. This demonstrates the significant performance benefit of partitioning for date-range queries.

---

### Question 7: External Table Storage
**Question**: Where is the data stored in the External Table you created?

**Answer**: **GCP Bucket**

**Explanation**: 
External tables in BigQuery are metadata-only tables that reference data stored in external sources like Google Cloud Storage (GCS buckets). The actual data remains in the GCS bucket and is read at query time.

---

### Question 8: Clustering Best Practices
**Question**: Is it best practice in BigQuery to always cluster your data?

**Answer**: **False**

**Explanation**: 
Clustering is beneficial but not always necessary:
- **Use clustering when**: You have high-cardinality columns frequently used in filters or joins
- **Don't use clustering when**: 
  - Tables are small (< 1 GB)
  - You don't have consistent query patterns
  - The clustering columns have low cardinality
  - You're already using partitioning and it provides sufficient performance

Clustering adds overhead to data ingestion and may not provide benefits for all use cases.

---

### Question 9: Understanding Table Scans (No Points)
**Question**: Write a `SELECT count(*)` query from the materialized table. How many bytes does it estimate will be read? Why?

**SQL Query**:
```sql
SELECT COUNT(*) 
FROM `dtc-w3-homework.yellow_tripdata.yellow_taxi_materialized`;
```

**Answer**: **0 MB**

**Explanation**: 
BigQuery maintains metadata statistics about tables, including the total row count. When you execute `SELECT COUNT(*)` without any WHERE clause or column references, BigQuery can return the result directly from metadata without scanning any actual data. This is an optimization that makes count queries extremely fast and efficient.

---

## Summary of Answers

| Question | Answer |
|----------|--------|
| Q1 | 20,332,093 |
| Q2 | 0 MB for the External Table and 155.12 MB for the Materialized Table |
| Q3 | BigQuery is a columnar database, and it only scans the specific columns requested |
| Q4 | 128,210 |
| Q5 | Partition by tpep_dropoff_datetime and Cluster on VendorID |
| Q6 | 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table |
| Q7 | GCP Bucket |
| Q8 | False |
| Q9 | 0 MB (uses metadata) |

---

## Files in This Repository

- `README.md` - This file containing all solutions
- `queries.sql` - All SQL queries used for the homework
- `setup.sql` - Table creation scripts

---

## Notes

- Replace `your-bucket-name` with your actual GCS bucket name
- Ensure you have proper permissions to access BigQuery and GCS
- The estimated bytes may vary slightly depending on your exact data and BigQuery optimizations
