# Metadata Functions
Functions supporting metadata-based analysis and automation.

### deploy_table_shard_metadata
The `deploy_table_shard_metadata` function deploys a table function to analyse sharded table data across datasets. 

Argument | Data Type | Description
--- | --- | ---
**`options`** | **`JSON`** | Options object consisting of `monitor_dataset_id` and `dataset_ids` options


#### Options
The `options` JSON object has the following structure:

```json
{
  "monitor_dataset_id": "project_id.dataset_id",
  "dataset_ids": ["project_id.dataset_id_x", "project_id.dataset_id_y"]
}
```

Any tables in the datasets identified by the `dataset_ids` with a valid date suffix will be included.

#### Deployment
The outcome of executing this function is the table function `monitor_tables` deployed in the desination `monitor_dataset_id` dataset, which can be queried to return a live summary of table metadata. There are also additional flags, thresholds, data conversions and computations to make subsequent logical operations and integrations as simple, concise and readable as possible. 

Estimated lifetime costs per date shard are also included, supporting aggregated analysis of total incurred storage cost by table prefix.

The script to deploy the `table_shard_metadata` function into the  `monitor_dataset_id` dataset, locate in the `eu` multi-region is therefore:

```sql
DECLARE options JSON;

SET options = JSON '''{
  "monitor_dataset_id": "project_id.MONITOR",
  "dataset_ids": ["project_id.dataset_id_x", "project_id.dataset_id_y"]
}''';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.eu.deploy_table_shard_metadata`(options)
);
```

Note that executing this script _without_ the `EXECUTE IMMEDIATE` wrapper around the `deploy_table_shard_metadata` function will return the DDL statement to be executed - useful for debugging and verification. 

Here the dataset name is `MONITOR` but this can be configured as required. Functions can be edited as needed, and note that renaming functions serves the purpose of 'forking' them locally as they will then not be overwritten by subsequent deployments. If a function _has_ been edited but _not_ renamed, a subsquent deployment will overwrite the edited function.
