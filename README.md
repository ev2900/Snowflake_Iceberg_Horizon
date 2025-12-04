# Snowflake Iceberg Horizon
<img width="275" alt="map-user" src="https://img.shields.io/badge/cloudformation template deployments-000-blue"> <img width="85" alt="map-user" src="https://img.shields.io/badge/views-0000-green"> <img width="125" alt="map-user" src="https://img.shields.io/badge/unique visits-000-green">

<img width="500" alt="quick_setup" src="https://github.com/ev2900/Snowflake_Iceberg_Horizon/blob/main/README/Architecture.png">

## Example

You can test this integration. Begin by deploying the CloudFormation stack below. This will create the required AWS resources.

> [!WARNING]
> The CloudFormation stack creates IAM role(s) that have ADMIN permissions. This is not appropriate for production deployments. Scope these roles down before using this CloudFormation in production.

[![Launch CloudFormation Stack](https://sharkech-public.s3.amazonaws.com/misc-public/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=snowflake-iceberg-gdc&templateURL=https://sharkech-public.s3.amazonaws.com/misc-public/snowflake_iceberg_horizon.yaml)
