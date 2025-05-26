# datatovalue-tools

The **`datatovalue-tools`** library extends Google BigQuery to simplify common Analytics Engineering use-cases which we encounter daily  working with clients at [Data to Value](https://datatovalue.com/). 

More specifically, the library comprises a set of utility functions to support data profiling, debugging, root-cause analysis and automation activities in data transformation and management. It is developed and maintained by the Engineering Team at Data to Value and is licensed under Apache 2.0. 

If you are interested in making a contribution or suggestion, please contact `jim@datatovalue.com`.

## Functions
The following sets of functions are deployed in the **datatovalue-tools** Google Cloud project, across all available regions.

Function Set | Description
--- | ---
[Profile Functions](docs/profile_functions.md) | Functions to support data quality assurance activities by modelling, integrating and analysing table contents and metadata.
[JSON Functions](docs/json_functions.md) | Functions to support automatic schema parsing and JSON parser deployment, to support accurate data transfer and efficient data pipeline development.
[SQL Parsers](docs/sql_parsers.md) | Functions which parse SQL queries and derive the logical structure and dependency graph.
[Monitor Functions](docs/monitor_functions.md) | Functions which are used to monitor BigQuery resources and resource status.
[Metadata Functions](docs/metadata_functions.md) |

## Deployment
Functions are live and deployed across in the `datatovalue-tools` BigQuery project for all global regions and multi-regions. Note that the dataset names contain underscores instead of dashes (e.g. functions in `europe-north1` are in the dataset `datatovalue-tools.europe_north1`).

## Permissions
Functions can be called by any user with `BigQuery Data Viewer`, `BigQuery Data User` or higher permissions on your source data. All authenticated users are permitted to call functions in the `datatovalue-tools` regional datasets.
