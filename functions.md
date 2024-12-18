# Functions

## row_duplicate_query
The `row_duplicate_query` is used to identify duplicate rows in any table.

Argument | Data Type | Description
--- | --- | ---
table_id | STRING | Fully signed ID of the table to be profiled.

It can be executed using the following syntax:

```sql
DECLARE table_id STRING;

SET table_id = 'project_a.dataset_a.table_a';

EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.row_duplicate_query` (
table_id));
```

The result will be the original table, with some additional metadata columns. The boolean column `duplicate_row_flag`  identifies duplicate rows in the data.

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
SELECT `datatovalue-tools.us_west1.row_duplicate_query` (
table_id, 
column_names
));
```

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