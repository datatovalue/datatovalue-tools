# datatovalue-tools

Data to Value Tools are BigQuery utility functions to support data profiling, debugging and root-cause analysis in data transformation and management.

## Functions
The following functions are deployed in the **datatovalue-tools** Google Cloud project. Function documentation is [here](functions.md).

Function | Description
--- | ---
[table_date_partitions_query](functions.md#table_date_partitions_query) | Profiles table date partition existence across datasets and identies gaps
[row_duplicate_query](functions.md#row_duplicate_query) | Flags exact duplicate rows in a table
[column_profile_query](functions.md#column_profile_query) | Profiles table column values for min/max/null counts
[unique_combination_query](functions.md#unique_combination_query) | Computes uniqueness across sets of table columns
[unique_combination_multi_query](functions.md#unique_combination_multi_query) | Computes uniqueness across sets of table columns for multiple table and column combinations

## Deployment

Functions are live and deployed across in the `datatovalue-tools` BigQuery project for all global regions and multi-regions. Deployment regions are set via the `regions` variable in the [terraform.tfvars](https://github.com/datatovalue/datatovalue-tools/blob/main/terraform/terraform.tfvars) file and builld and deploy to the corresponding geographic dataset in the `datatovalue-tools` BigQuery project. Note that the dataset names contain unserscores instead of dashes.

Functions are deployed using Terraform and function source code is version-controlled in separate sql files in the `terraform/functions` directory of the `datatovalue/datatovalue-tools` respository.

## Usage
Functions receive arguments and return SQL, which can be executed in order to obtain the desired result set, or used to create sql-defined resources. The following actions are achieved via these corresponding approaches:

Action | Approach
--- | ---
[View SQL](#view-sql) | Invoke function via `SELECT` statement
[Execute SQL](#execute-sql) | `EXECUTE IMMEDIATE` function
[Save Results](#save-results) | `Save Results` from executed SQL via the user interface
[Create Table](#create-table) | Append DDL prefix string and `EXECUTE IMMEDIATE`
[Create Temporary Table](#create-temporary-table) | Append DDL prefix string and `EXECUTE IMMEDIATE`
[Create View](#create-view) | Append DDL prefix string and `EXECUTE IMMEDIATE`

## Examples

The following examples assume that the source data is in the `us-west1` region for the `row_duplicate_query` function. For data in different regions simply replace the `us-west1` with the appropriate region identifier and the function invocation code with the desired function name and appropriate arguments.

### View SQL
In order to view the SQL which has been generated, use a simple `SELECT` statement and pass the `table_id`:

```sql
SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a');
```

### Execute SQL
To execute the query this can simply be wrapped in an `EXECUTE IMMEDIATE` statement:

```sql
EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a')
);
```
For syntactic clarity it is often desirable to explicitly define the `query` string variable and use the function to set the value.

```sql
DECLARE query STRING;

SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a'));

EXECUTE IMMEDIATE (query);
```

### Save Results
This result can then be saved as a table by clicking on `Save Results` in the user interface. 

### Create Table
To create the table in one statement, simple append the required DDL to the beginning of the query and use the `EXECUTE IMMEDIATE` statement on the combined query:

```sql
DECLARE query STRING;

SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a'));

SET query = "CREATE OR REPLACE TABLE `project_a.dataset_a.new_table` AS "||query;

EXECUTE IMMEDIATE (query);
```

Note that options and partitioning/clustering can be also included here to customize the destination table properties.

### Create Temporary Table
To create the temporary table in one statement, simple append the required DDL to the beginning of the query and use the `EXECUTE IMMEDIATE` statement on the combined query:

```sql
DECLARE query STRING;

SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a'));

SET query = "CREATE OR REPLACE TEMP TABLE `temp_table_name` AS "||query;

EXECUTE IMMEDIATE (query);
```

Now the temporary table can be referenced by alias for the duration of the session.

#### Create View
To create a view (which makes the generated code available to edit), the syntax is analagous:

```sql
DECLARE query STRING;

SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project_a.dataset_a.table_a'));

SET query = "CREATE OR REPLACE VIEW `project_a.dataset_a.new_table` AS "||query;

EXECUTE IMMEDIATE (query);
```