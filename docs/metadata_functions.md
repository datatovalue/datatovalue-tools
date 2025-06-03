# Metadata Functions
Functions supporting metadata-based analysis and automation.

Note that executing these scripts _without_ the `EXECUTE IMMEDIATE` wrapper around the deployment function will return the DDL statement to be executed - useful for debugging and verification. 

Here the dataset name is `MONITOR` but this can be configured as required. Functions can be edited as needed, and note that renaming functions serves the purpose of 'forking' them locally as they will then not be overwritten by subsequent deployments. If a function _has_ been edited but _not_ renamed, a subsquent deployment will overwrite the edited function.

### deploy_table_shard_metadata
The `deploy_table_shard_metadata` function deploys the `table_shard_metadata` table function to analyse sharded table data across datasets. 

The Medium article referencing this function [Analyzing Google Analytics 4 Storage Cost in BigQuery](https://datatovalue.blog/analyzing-google-analytics-4-storage-cost-in-bigquery-8e68878559b7) contains a number of examples demonstrating how to query this metadata table function.


Argument | Data Type | Description
--- | :-: | ---
**`options`** | **`JSON`** | Options object consisting of `monitor_dataset_id` and `dataset_ids` options.


#### Options

Option | Data Type | Description
--- | :-: | ---
**`monitor_dataset_id`** | **`STRING`** | The ID of the dataset in which the `table_shard_metadata` will be deployed.
**`dataset_ids`** | **`ARRAY<STRING>`** | An array of dataset IDs for which we want to analyze metadata.


The `options` JSON object therefore has the following structure:

```json
{
  "monitor_dataset_id": "project_id.dataset_name",
  "dataset_ids": ["project_id.dataset_name_x", "project_id.dataset_name_y"]
}
```

Any tables in the datasets in `dataset_ids` with a valid date suffix will be included.

#### Deployment
The outcome of executing this function is the table function `monitor_tables` deployed in the destination `monitor_dataset_id` dataset, which can be queried to return a live summary of table metadata. There are also additional flags, thresholds, data conversions and computations to make subsequent logical operations and integrations as simple, concise and readable as possible. 

Estimated lifetime costs per date shard are also included, supporting aggregated analysis of total incurred storage cost by table prefix.

The script to deploy the `table_shard_metadata` function into the  `monitor_dataset_id` dataset, located in the `eu` multi-region is therefore:

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

### deploy_storage_billing_model
The `deploy_storage_billing_model` function deploys the `storage_billing_model` table function. This identifies the storage billing models for all datasets in a project and computes relative cost by table for `PHYSICAL` vs. `LOGICAL` Storage Billing Models. It is used to identify potential costs savings by switching billing model.

Argument | Data Type | Description
--- | :-: | ---
**`options`** | **`JSON`** | Options object consisting of `project_id` and `monitor_dataset_id` options.

#### Options
Option | Data Type | Description
--- | :-: | ---
**`project_id`** | **`STRING`** | The ID of the project for which we want to analyze metadata.
**`monitor_dataset_id`** | **`STRING`** | The ID of the dataset into which the `storage_billing_model` table function will be deployed.

The `options` JSON object therefore has the following structure:

```json
{
  "project_id": "project_id",
  "monitor_dataset_id": "project_id.monitor_dataset_name"
}
```

All datasets in the project set by the `project_id` option will be included.

#### Deployment
The outcome of executing this function is the table function `storage_billing_model` deployed in the destination `monitor_dataset_id` dataset, which can be queried to return a live summary of table metadata. There are also additional flags, thresholds, data conversions and computations to make subsequent logical operations and integrations as simple, concise and readable as possible. 

Estimated potential monthly and annual cost savings are also included, supporting quantification of any the cost opportunity from switching billing storage model.

The script to deploy the `storage_billing_model` function into the  `monitor_dataset_id` dataset, located in the `eu` multi-region is therefore:

```sql
DECLARE options JSON;

SET options = JSON '''{
  "project_id": "project_id",
  "monitor_dataset_id": "project_id.monitor_dataset_name"
  }''';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.eu.deploy_storage_billing_model`(options)
);
```


