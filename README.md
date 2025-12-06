# Snowflake Iceberg Horizon
<img width="275" alt="map-user" src="https://img.shields.io/badge/cloudformation template deployments-24-blue"> <img width="85" alt="map-user" src="https://img.shields.io/badge/views-0000-green"> <img width="125" alt="map-user" src="https://img.shields.io/badge/unique visits-000-green">

Snowflake can manager (read and write) Iceberg tables. This intergration works via. an external volume in Snowflake pointing to the S3 bucket with Iceberg.

The architecture below depicts this

<img width="500" alt="quick_setup" src="https://github.com/ev2900/Snowflake_Iceberg_Horizon/blob/main/README/Architecture.png">

## Example

You can test this integration. Begin by deploying the CloudFormation stack below. This will create the required AWS resources.

> [!WARNING]
> The CloudFormation stack creates IAM role(s) that have ADMIN permissions. This is not appropriate for production deployments. Scope these roles down before using this CloudFormation in production.

[![Launch CloudFormation Stack](https://sharkech-public.s3.amazonaws.com/misc-public/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=snowflake-iceberg-horizon&templateURL=https://sharkech-public.s3.amazonaws.com/misc-public/snowflake_iceberg_horizon.yaml)

### Create an external volume in Snowflake

**NOTE** the values of any of the <...> place holders can be found in the output section of the CloudFormation stack

<img width="700" alt="quick_setup" src="https://github.com/ev2900/Snowflake_Iceberg_Horizon/blob/main/README/cf_output.png">

Update and run the following SQL in Snowflake.

```
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
```

### Update IAM role allowing Snowflake to assume it

Before you can use the external volume to create an external table with S3 back storage, you need to update the IAM role Snowflake will use. Specifically, you need to update the role so Snowflake can assume it.

To update the IAM role you will deploy a stack update to the CloudFormation template.

Begin by selecting the CloudFormation stack and then *Update stack*, *Make a direct update*

<img width="700" alt="quick_setup" src="https://github.com/ev2900/Snowflake_Iceberg_Horizon/blob/main/README/update_cf.png">

Then select *Replace existing tempalte* and copy paste the following S3 URL

```https://sharkech-public.s3.amazonaws.com/misc-public/snowflake_iceberg_horizon_iam_update.yaml```

On the next page you will be asked for several inputs. Run the following SQL in Snowflake to get each input parameter

**STORAGE_AWS_EXTERNAL_ID and STORAGE_AWS_IAM_USER_ARN**
```
-- Step 2 | Get STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID to update IAM role
DESC EXTERNAL VOLUME EXT_VOL_HORIZON_S3;

SELECT
	parse_json("property_value"):STORAGE_AWS_IAM_USER_ARN::string AS storage_aws_iam_user_arn,
    parse_json("property_value"):STORAGE_AWS_EXTERNAL_ID::string AS storage_aws_external_id
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "property" = 'STORAGE_LOCATION_1';
```

The parameters page on the CloudFormation stack update should look like this

<img width="700" alt="quick_setup" src="https://github.com/ev2900/Snowflake_Iceberg_Horizon/blob/main/README/cf_update_2.png">

Continue clicking *Next* and *Submit

### Create an Iceberg table

Run the following SQL to a create an Iceberg table Snowflake

```
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
```

### Write to the Iceberg table

Run the following SQL to write a few rows of sample data

```
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
```
