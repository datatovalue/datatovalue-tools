# datatovalue-tools

**`datatovalue-tools`** extend Google BigQuery to simplify common Analytics Engineering use-cases, which we encounter daily when working with clients at Data to Value. 

More specifically, the library comprises a set of utility functions to support data profiling, debugging, root-cause analysis and automation activities in data transformation and management. It is developed and manitained by the Engineering Team at [Data to Value](https://datatovalue.com/) and are licensed under Apache 2.0. If you are interested in making a contribution or suggestion, please contact `jim@datatovalue.com`.

## Functions
The following sets of functions are deployed in the **datatovalue-tools** Google Cloud project, across all available regions.

Function Set | Description
--- | ---
[Infoschema Functions](docs/infoschema_functions.md) | Functional implementation of the [INFORMATION_SCHEMA](https://cloud.google.com/bigquery/docs/information-schema-intro) metadata views to support automation activities. 
[Profiling Functions](docs/profiling_functions.md) | Functions to support data quality assurance activities by modelling, integrating and analysing table contents and metadata.
[JSON Functions](docs/json_functions.md) | Functions to support automatic schema parsing and JSON parser deployment, to support accurate data transfer and efficient data pipeline development.
[SQL Parsers](docs/sql_parsers.md) | Functions which parse SQL queries and derive the logical structure and dependency graph.
[Monitor Functions](docs/monitor_functions.md) | Functions which are used to monitor BigQuery resources and resource status.

## Deployment
Functions are live and deployed across in the `datatovalue-tools` BigQuery project for all global regions and multi-regions. Note that the dataset names contain underscores instead of dashes (e.g. functions in `europe-north1` are in the dataset `datatovalue-tools.europe_north1`).

Functions are deployed using Terraform and function source code is version-controlled in separate sql files in the `terraform/functions` directory of the `datatovalue/datatovalue-tools` respository.

## Permissions
Functions can be called by any user with `BigQuery Data Viewer`, `BigQuery Data User` or higher permissions on your source data. All authenticated users are permitted to call functions in the `datatovalue-tools` regional datasets.

## Usage

Function usage syntax and examples are contained in the [Usage Guide](docs/guides/usage.md).
