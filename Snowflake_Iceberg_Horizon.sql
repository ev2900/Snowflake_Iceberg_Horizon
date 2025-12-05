-- Optional create a new database
CREATE DATABASE IF NOT EXISTS ICEBERG;

-- Step 1 | Create external volume to link S3 bucket with Snowflake
CREATE OR REPLACE EXTERNAL VOLUME EXT_VOL_HORIZON_S3
   STORAGE_LOCATIONS =
      (
         (
            NAME = 's3-iceberg-external-volume'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = '<s3_uri>' -- ex. s3://snowflake-iceberg-gdc-s3-h76rxnfdokx7/iceberg/
            STORAGE_AWS_ROLE_ARN = '<arn_snowflake_IAM_role>' -- ex. arn:aws:iam::535002871755:role/snowflake-iceberg-gdc-SnowflakeIAMRole-DyzKjswvzs7H
         )
      );

SHOW EXTERNAL VOLUMES;

-- Step 2 | Get STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID to update IAM role
DESC EXTERNAL VOLUME EXT_VOL_HORIZON_S3;

SELECT
	parse_json("property_value"):STORAGE_AWS_IAM_USER_ARN::string AS storage_aws_iam_user_arn,
    parse_json("property_value"):STORAGE_AWS_EXTERNAL_ID::string AS storage_aws_external_id
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "property" = 'STORAGE_LOCATION_1';

-- Step 3 | Create an Iceberg table
CREATE OR REPLACE ICEBERG TABLE SAMPLEDATA_ICEBERG_HORIZON  
  CATALOG='SNOWFLAKE'
  EXTERNAL_VOLUME='EXT_VOL_HORIZON_S3'
  BASE_LOCATION='sampledatahorizon'
(
    quote_id        VARCHAR,
    customer_id     VARCHAR,
    premium_amount  DOUBLE,
    status          STRING,
    created_at      TIMESTAMP
);

-- Step 4 | Insert a few rows of data
INSERT INTO SAMPLEDATA_ICEBERG_HORIZON (
    quote_id,
    customer_id,
    premium_amount,
    status,
    created_at
)
VALUES
    ('Q-1001', 'CUST-001', 125.50, 'PENDING',     '2025-01-10 14:23:00'),
    ('Q-1002', 'CUST-002', 210.75, 'APPROVED',   '2025-01-11 09:15:22'),
    ('Q-1003', 'CUST-003', 340.00, 'REJECTED',   '2025-01-12 16:42:10'),
    ('Q-1004', 'CUST-001', 180.25, 'PENDING',    '2025-01-13 11:05:47'),
    ('Q-1005', 'CUST-004', 295.99, 'APPROVED',   '2025-01-14 08:33:19');

-- Optional query the table
SELECT * FROM SAMPLEDATA_ICEBERG_HORIZON LIMIT 10;
