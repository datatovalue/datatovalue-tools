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

### set_dataset_options
The `set_dataset_options` function updates the options on a dataset, updating metadata in line with the [schema_set_options_list](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language#schema_set_options_list).

Argument | Data Type | Description
--- | :-: | ---
**`options`** | **`JSON`** | Options object.

#### Options
Option | Data Type | Description
--- | :-: | ---
**`dataset_id`** | **`STRING`** | REQUIRED. The ID of the dataset to update options.
**`storage_billing_model`** | **`STRING`** | Alters the storage billing model for the dataset. Set the storage_billing_model value to PHYSICAL to use physical bytes when calculating storage charges, or to LOGICAL to use logical bytes. LOGICAL is the default. When you change a dataset's billing model, it takes 24 hours for the change to take effect. Once you change a dataset's storage billing model, you must wait 14 days before you can change the storage billing model again. 

The `options` JSON object therefore has the following structure:

```json
{
  "dataset_id": "project_id.dataset_name",
  "storage_billing_model": "PHYSICAL"
}
```

#### Deployment
The outcome of executing this function is the updated metadata of the `dataset_id` dataset.

The script to update dataset metadata using the `set_dataset_options` function is therefore:

```sql
DECLARE options JSON;

SET options = JSON '''{
  "dataset_id": "project_id.dataset_name",
  "storage_billing_model": "PHYSICAL"
  }''';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.eu.set_dataset_options`(options)
);
```
This can be used in conjunction with the `deploy_storage_billing_model` to automate the optimization of storage billing model selection.

