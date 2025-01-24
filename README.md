# infoschema functions

The `infoschema` functions make BigQuery [INFORMATION SCHEMA](https://cloud.google.com/bigquery/docs/information-schema-intro) metadata accessible via parameterised table functions, without requiring hard-coding of region, project, dataset or table identifiers. This enables them to be used in programmatic metadata-driven use-cases such as data profiling, monitoring and templated dashboard development.

Functions are available in all Google Cloud regions. Note that in the examples below, the `my_region` placeholder needs to be replaced with a region identifier from any [BigQuery region](https://cloud.google.com/bigquery/docs/locations#regions). 

All columns are retained from the associated `INFORMATION_SCHEMA` view, with an additional `id` added as the first column based on the metadata granularity of the response (i.e. `dataset_id` or `table_id`) for ease of subsequent manipulation and integration. Data types and structures are corrected where necessary, and column names for projects, datasets and tables are standardised to `project_id`, `dataset_name` and `table_name`. 

- `dataset_id` = `project_id.dataset_name`
- `project_id` = `project_id.dataset_name.table_name`.

Additional fields are added in the following scenarios:
- Unix timestamp fields have a `TIMESTAMP` equivalent field added.
- Bytes values have a GiB field added (divided by $1024^3$).
- Labels are converted to a JSON object, which can be queried directly using the label key: `SELECT JSON_VALUE(label_column, '$label_key') AS label key`.

## Function Reference
### infoschema.datasets
This is a functional implementation of the [INFORMATION_SCHEMA.SCHEMATA](https://cloud.google.com/bigquery/docs/information-schema-datasets-schemata) view.

Argument | Data Type | Description
--- | --- | ---
`region` | `STRING` | The region from which to retrieve dataset-level metadata

```sql 
DECLARE region, datasets_query STRING;
DECLARE datasets_json JSON;

SET region = "my_region" ; 

SET datasets_query = (SELECT `datatovalue-tools.my_region`.datasets_query(region));
EXECUTE IMMEDIATE (datasets_query) INTO datasets_json;
SELECT * FROM `datatovalue-tools.my_region`.datasets(datasets_json);
```

### infoschema.tables
This is a functional implementation of the [INFORMATION_SCHEMA.TABLES](https://cloud.google.com/bigquery/docs/information-schema-tables) view.

Argument | Data Type | Description
--- | --- | ---
`dataset_ids` | `ARRAY<STRING>` | The datasets from which to retrieve table-level metadata.

```sql
DECLARE dataset_ids ARRAY<STRING>;
DECLARE tables_query STRING; 
DECLARE tables_json JSON;

SET dataset_ids = ["dataset_id_a", "dataset_id_b", ... ];

SET tables_query = (SELECT `datatovalue-tools.my_region`.tables_query(dataset_ids));
EXECUTE IMMEDIATE (tables_query) INTO tables_json;
SELECT * FROM `datatovalue-tools.my_region`.tables(tables_json);  
```

### infoschema.table_metadata
This is a functional implementation of the BigQuery `__TABLES__` metadata view.

Argument | Data Type | Description
--- | --- | ---
`dataset_ids` | `ARRAY<STRING>` | The datasets from which to retrieve table-level metadata.

```sql
DECLARE dataset_ids ARRAY<STRING>;
DECLARE table_metadata_query STRING; 
DECLARE table_metadata_json JSON;

SET dataset_ids = ["dataset_id_a", "dataset_id_b", ... ];

SET table_metadata_query = (SELECT `datatovalue-tools.my_region`.table_metadata_query(dataset_ids));
EXECUTE IMMEDIATE (table_metadata_query) INTO table_metadata_json;     
SELECT * FROM `datatovalue-tools.my_region`.table_metadata(table_metadata_json);
```

### infoschema.table_options
This is a functional implementation of the [INFORMATION_SCHEMA.TABLE_OPTIONS](https://cloud.google.com/bigquery/docs/information-schema-table-options) view. The reponse is restructured from key-value pairs into columns for ease of subsequent manipulation.

Argument | Data Type | Description
--- | --- | ---
`dataset_ids` | `ARRAY<STRING>` | The datasets from which to retrieve table-level metadata.

```sql
DECLARE dataset_ids ARRAY<STRING>;
DECLARE table_options_query STRING; 
DECLARE table_options_json JSON;

SET dataset_ids = ["dataset_id_a", "dataset_id_b", ... ];

SET table_options_query = (SELECT `datatovalue-tools.my_region`.table_options_query(dataset_ids));
EXECUTE IMMEDIATE (table_options_query) INTO table_options_json;
SELECT * FROM `datatovalue-tools.my_region`.table_options(table_options_json);
```

### infoschema.table_storage
This is a functional implementation of the [INFORMATION_SCHEMA.TABLE_STORAGE](https://cloud.google.com/bigquery/docs/information-schema-table-storage) view.

Argument | Data Type | Description
--- | --- | ---
`project_id` | `STRING` | The project from which to retrieve table-level storage metadata.
`region` | `STRING` | The region from which to retrieve table-level storage metadata.

```sql
DECLARE region, project_id, table_storage_query STRING;
DECLARE table_storage_json JSON;

SET project_id = "my_project_id";
SET region = "my_region";

SET table_storage_query = (SELECT `datatovalue-tools.my_region`.table_storage_query(project_id, region));
EXECUTE IMMEDIATE (table_storage_query) INTO table_storage_json;
SELECT * FROM `datatovalue-tools.my_region`.table_storage(table_storage_json);
```

### infoschema.partitions
This is a functional implementation of the [INFORMATION_SCHEMA.PARTITIONS](https://cloud.google.com/bigquery/docs/information-schema-partitions) view. 

Argument | Data Type | Description
--- | --- | ---
`table_ids` | `ARRAY<STRING>` | The tables from which to retrieve partition-level metadata.

```sql
DECLARE table_ids ARRAY<STRING>;
DECLARE partitions_query STRING; 
DECLARE partitions_json JSON;

SET table_ids = ["table_id_a", "table_id_b", ... ];

SET partitions_query = (SELECT `datatovalue-tools.`.partitions_query(table_ids));
EXECUTE IMMEDIATE (partitions_query) INTO partitions_json;
SELECT * FROM `datatovalue-tools.us_west1`.partitions(partitions_json);
```

### infoschema.columns
This is a functional implementation of the [INFORMATION_SCHEMA.COLUMNS](https://cloud.google.com/bigquery/docs/information-schema-columns) view. 

Argument | Data Type | Description
--- | --- | ---
`dataset_ids` | `ARRAY<STRING>` | The datasets from which to retrieve column-level metadata.

```sql
DECLARE dataset_ids ARRAY<STRING>;
DECLARE columns_query STRING; 
DECLARE columns_json JSON;

SET dataset_ids = ["dataset_id_a", "dataset_id_b", ... ];

SET columns_query = (SELECT `datatovalue-tools.my_region`.columns_query(dataset_ids));
EXECUTE IMMEDIATE (columns_query) INTO columns_json;
SELECT * FROM `datatovalue-tools.my_region`.columns(columns_json);
```

### infoschema.column_field_paths
This is a functional implementation of the [INFORMATION_SCHEMA.COLUMN_FIELD_PATHS](https://cloud.google.com/bigquery/docs/information-schema-columns) view. 

Argument | Data Type | Description
--- | --- | ---
`dataset_ids` | `ARRAY<STRING>` | The datasets from which to retrieve column-level metadata.

```sql
DECLARE dataset_ids ARRAY<STRING>;
DECLARE column_field_paths_query STRING; 
DECLARE column_field_paths_json JSON;

SET dataset_ids = ["dataset_id_a", "dataset_id_b", ... ];

SET column_field_paths_query = (SELECT `datatovalue-tools.my_region`.column_field_paths_query(dataset_ids));
EXECUTE IMMEDIATE (column_field_paths_query) INTO column_field_paths_json;
SELECT * FROM `datatovalue-tools.my_region`.column_field_paths(column_field_paths_json);
```



