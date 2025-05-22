# Monitor Functions
Functions which model and integrate metadata to provide useful insight on BigQuery resources.

### monitor_tables
The `monitor_tables` function models table metadata into a structure which supports monitoring of table freshness across multiple tables and datasets. The `config` JSON object is used to define the deployment location, which specific tables to monitor and their threshold values for expected freshness.

It is used as the logical foundation for a simple, BigQuery-native monitoring layer, comprising dashboards and automated alerting via Slack and email.

Argument | Data Type | Description
--- | --- | ---
**`config`** | **`JSON`** | Configuration object consiting of `monitor_dataset_id` and `tables` options

#### Configuration
The `config` JSON object argument has the following structure:

```json
{
  "monitor_dataset_id": "project_id.MONITOR",
  "tables": [
    {"table_id": "project_id.dataset_name.table_name_x", "alert_threshold_hrs": 25},
    {"table_id": "project_id.dataset_name.table_name_y", "alert_threshold_hrs": 25},
    {"table_id": "project_id.dataset_name.table_name_z", "alert_threshold_hrs": 1.0}
]
}
```

Only specific tables identified in the `tables` array will be represented in the output table function.


#### Deployment
The outcome of executing this function is the table function `monitor_tables` deployed in the desination `monitor_dataset_id` dataset, which can be queried to return a live summary of table metadata. There are also additional flags, thresholds, data conversions and computations to make subsequent logical operations and integrations as simple, concise and readable as possible. 

The script to deploy the `monitor_tables` function into the  `monitor_dataset_id` is therefore:

```sql
DECLARE config JSON;

SET config = JSON '''{
  "monitor_dataset_id": "project_id.MONITOR",
  "tables": [
    {"table_id": "project_id.dataset_name.table_name_x", "alert_threshold_hrs": 24},
    {"table_id": "project_id.dataset_name.table_name_y", "alert_threshold_hrs": 24},
    {"table_id": "project_id.dataset_name.table_name_z", "alert_threshold_hrs": 1.0}
    ]
  }''';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.eu.deploy_monitor_tables`(config)
);
```

Note that executing this script _without_ the `EXECUTE IMMEDIATE` wrapper around the `deploy_monitor_table` function will return the DDL statement to be executed - useful for debugging and verification. 

Here the dataset name is `MONITOR` but this can be configured as required. Functions can be edited as needed, and note that renaming functions serves the purpose of 'forking' them locally as they will then not be overwritten by subsequent deployments. If a function _has_ been edited but _not_ renamed, a subsquent deployment will overwrite the edited function.
