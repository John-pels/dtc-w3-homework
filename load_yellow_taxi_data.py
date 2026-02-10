"""
Script to download and upload Yellow Taxi Trip Records to Google Cloud Storage
For Module 3 Homework - January to June 2024 data
"""

import os
import requests
from google.cloud import storage
from datetime import datetime

# Configuration
BUCKET_NAME = "your-bucket-name"  # Replace with your GCS bucket name
PROJECT_ID = "your-project-id"    # Replace with your GCP project ID
LOCAL_DOWNLOAD_PATH = "./data"    # Local directory to temporarily store files

# NYC Taxi Data URLs for January - June 2024
BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data"
MONTHS = ["01", "02", "03", "04", "05", "06"]
YEAR = "2024"


def download_file(url, local_path):
    """Download a file from URL to local path"""
    print(f"Downloading {url}...")
    response = requests.get(url, stream=True)
    response.raise_for_status()
    
    os.makedirs(os.path.dirname(local_path), exist_ok=True)
    
    with open(local_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)
    
    print(f"Downloaded to {local_path}")


def upload_to_gcs(bucket_name, source_file_path, destination_blob_name):
    """Upload a file to Google Cloud Storage"""
    print(f"Uploading {source_file_path} to gs://{bucket_name}/{destination_blob_name}...")
    
    storage_client = storage.Client(project=PROJECT_ID)
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    
    blob.upload_from_filename(source_file_path)
    
    print(f"File uploaded to gs://{bucket_name}/{destination_blob_name}")


def main():
    """Main function to download and upload taxi data"""
    print("Starting Yellow Taxi Data upload process...")
    print(f"Target bucket: {BUCKET_NAME}")
    print(f"Months: January - June {YEAR}")
    print("-" * 50)
    
    # Create local directory if it doesn't exist
    os.makedirs(LOCAL_DOWNLOAD_PATH, exist_ok=True)
    
    for month in MONTHS:
        filename = f"yellow_tripdata_{YEAR}-{month}.parquet"
        url = f"{BASE_URL}/{filename}"
        local_path = os.path.join(LOCAL_DOWNLOAD_PATH, filename)
        
        try:
            # Download file
            download_file(url, local_path)
            
            # Upload to GCS
            upload_to_gcs(BUCKET_NAME, local_path, filename)
            
            # Optional: Remove local file after upload to save space
            os.remove(local_path)
            print(f"Removed local file: {local_path}")
            
        except Exception as e:
            print(f"Error processing {filename}: {str(e)}")
            continue
        
        print("-" * 50)
    
    print("Upload process completed!")
    print(f"\nNext steps:")
    print(f"1. Verify all 6 files are in gs://{BUCKET_NAME}/")
    print(f"2. Create external table in BigQuery using these files")
    print(f"3. Run the queries from queries.sql")


if __name__ == "__main__":
    # Check if running with proper authentication
    if not os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
        print("WARNING: GOOGLE_APPLICATION_CREDENTIALS environment variable not set")
        print("Make sure you're authenticated with Google Cloud SDK or have a service account key")
        print("\nTo authenticate, run: gcloud auth application-default login")
        print("Or set: export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json")
        print()
    
    main()
