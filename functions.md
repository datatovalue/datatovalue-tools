# Functions

## table_date_partitions_query
The `table_date_partitions_query` is used to validate date partition existence across all tables in a single project, across multiple datasets. It also flags tables where there are gaps in the existing date partitions and identifies specific missing dates.

Argument | Data Type | Description
--- | --- | ---
`project_id` | `STRING` | Fully signed ID of the table to be profiled.
`dataset_names` | `ARRAY<STRING>` | An array containing the names of datasets to be profiled.

It can be executed using the following syntax:

```sql
DECLARE project_id STRING;
DECLARE dataset_names ARRAY<STRING>;

SET project_id = 'project_a';
SET dataset_names = ['dataset_a', 'dataset_b', 'dataset_c'];

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.table_partitions_query` (          
project_id, 
dataset_names));
```

## row_duplicate_query
The `row_duplicate_query` is used to identify duplicate rows in any table.

Argument | Data Type | Description
--- | --- | ---
`table_id` | `STRING` | Fully signed ID of the table to be profiled.

It can be executed using the following syntax:

```sql
DECLARE table_id STRING;

SET table_id = 'project_a.dataset_a.table_a';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.row_duplicate_query` (table_id));
```

The result will be the original table, with some additional metadata columns. The boolean column `duplicate_row_flag`  identifies duplicate rows in the data.

## column_profile_query
The `column_profile_query` is used compute column metrics such as minimum and maximum values, null values and null percentage.

Argument | Data Type | Description
--- | --- | ---
`table_id` | `STRING` | Fully signed ID of the table to be profiled.

Note that since this function needs to query the `INFORMATION_SCHEMA.COLUMNS` view to get the precise table columns, executing the returned query will return _another_ SQL query. This must in turn be executed in order to obtain the result.

This can be achieved using the following syntax:

```sql
DECLARE table_id, query STRING;

SET table_id = 'project_a.dataset_a.table_a';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.table_partitions_query` (project_id, dataset_names)
) INTO query;

EXECUTE IMMEDIATE (query);
```

## unique_combination_query
The `unique_combination_query` is used to validate whether combinations of columns are unique in any table. This supports validation of granularity assumptions and unique key development, testing and monitoring.

Argument | Data Type | Description
--- | --- | ---
`table_id` | `STRING` | Fully signed ID of the table to be profiled.
`column_names` | `ARRAY<STRING>` | An array containing the names of columns to be profiled.

It can be executed using the following syntax:

```sql
DECLARE table_id STRING;
DECLARE column_names ARRAY<STRING>;

SET table_id = 'project_a.dataset_a.table_a';
SET column_names = ['column_a', 'column_b', 'column_c'];

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.unique_combination_query` (table_id, column_names)
);
```

## unique_combination_multi_query
The `unique_combination_multi_query` is used to validate whether different combinations of columns are unique across multiple tables. This supports validation of granularity assumptions and unique key development, testing and monitoring, and is an extension of the `unique_combination_query` function.

Argument | Data Type | Description
--- | --- | ---
`ARRAY<STRUCT<table_id STRING, column_names ARRAY<STRING>>>` | Struct array of inputs containing multiple `table_id` and `column_names` combinations.

It can be executed using the following syntax:

```sql
DECLARE table_column_combinations ARRAY<STRUCT<table_id STRING, column_names ARRAY<STRING>>>;

SET table_column_combinations = [
    ('project_a.dataset_a.table_a', ["column_a"]),
    ('project_a.dataset_a.table_a', ["column_a", "column_b"]),
    ('project_a.dataset_a.table_a', ["column_a", "column_b", "column_c"]),
    ('project_a.dataset_a.table_a', ["column_a", "column_b", "column_c", "column_d"]),
    ];

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.unique_combination_multi_query` (table_column_combinations)
);
```
