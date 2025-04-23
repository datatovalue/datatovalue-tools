# datatovalue-tools

Data to Value Tools are BigQuery utility functions to support data profiling, debugging, root-cause analysis and automation activities in data transformation and management. They are developed and manitained by the Engineering Team at [Data to Value](https://datatovalue.com/) and are licensed under Apache 2.0. If you are interested in making a contribution or suggestion, please contact `jim@datatovalue.com`.

## Functions
The following sets of functions are deployed in the **datatovalue-tools** Google Cloud project, across all available regions.

Function Set | Description
--- | ---
[Infoschema Functions](docs/infoschema_functions.md) | Functional implementation of the [INFORMATION_SCHEMA](https://cloud.google.com/bigquery/docs/information-schema-intro) metadata views to support automation activities. 
[Profiling Functions](docs/profiling_functions.md) | Functions to support data quality assurance activities by modelling, integrating and analysing table contents and metadata.
[JSON Functions](docs/json_functions.md) | Functions to support automatic schema parsing and JSON parser deployment, to support accurate data transfer and efficient data pipeline development.

## Deployment

Functions are live and deployed across in the `datatovalue-tools` BigQuery project for all global regions and multi-regions. Deployment regions are set via the `regions` variable in the [terraform.tfvars](https://github.com/datatovalue/datatovalue-tools/blob/main/terraform/terraform.tfvars) file and builld and deploy to the corresponding geographic dataset in the `datatovalue-tools` BigQuery project. Note that the dataset names contain underscores instead of dashes.

Functions are deployed using Terraform and function source code is version-controlled in separate sql files in the `terraform/functions` directory of the `datatovalue/datatovalue-tools` respository.

## Permissions
Functions can be called by any user with `BigQuery Data Viewer`, `BigQuery Data User` or higher permissions on your source data. All authenticated users are permitted to call functions in the `datatovalue-tools` regional datasets.

```
SET query = "CREATE OR REPLACE VIEW `project_a.dataset_a.new_table` AS "||query;

EXECUTE IMMEDIATE (query);
```

## Usage

Function usage syntax and examples are contained in the [Usage Guide](docs/guides/usage.md).
