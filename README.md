# datatovalue-tools

## Data Quality Assurance Functions
Data Quality Assurance functions are utility functions to support data profiling, debugging and root-cause analysis in data transformations.

### Deployment

Functions are deployed across in the `datatovalue-tools` BigQuery project all global regions, including `eu` and `us` multi-regions. Deployment regions are set via the `regions` variable in the [terraform.tfvars](https://github.com/datatovalue/datatovalue-tools/blob/main/terraform/terraform.tfvars) file and align to the datasets in the `datatovalue-tools` BigQuery project. Note that the dataset names replace dashes with underscores (e.g. `us-west1` corresponds to the `us_west1` dataset).

Functions are deployed using Terraform and function source code is in separate text files in the `terraform/functions` directory of this `datatovalue/datatovalue-tools` respository.

### Usage
Functions receive arguments and return SQL, which can be executed in order to obtain the desired result set. The following actions are achieved via these corresponding approaches:

Action | Approach
--- | ---
View SQL | Invoke function via `SELECT` statement
Execute SQL | `EXECUTE IMMEDIATE` function
Save Results | `Save Results` from executed SQL via the user interface
Create View | Append DDL prefix string and `EXECUTE IMMEDIATE`
Create Table | Append DDL prefix string and `EXECUTE IMMEDIATE`

The following examples assume that the source data is in the `us-west1`region for the `row_duplicate_query` function. For data in different regions simply replace the `us-west1` with the appropriate region identifier and the function invocation code with the desired function name and appropriate arguments.

#### View SQL
In order to view the SQL which has been generated, use a simple `SELECT` statement and pass the `table_id`:

```sql
SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project.dataset.table');
```

#### Execute SQL
To execute the query this can simply be wrapped in an `EXECUTE IMMEDIATE` statement:

```sql
EXECUTE IMMEDIATE (
SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project.dataset.table'));
```
For syntactic clarity it is often desirable to explicitly define the `query` string variable and use the function to set the value.

```sql
DECLARE query STRING;
SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project.dataset.table'));
EXECUTE IMMEDIATE (query);
```

#### Save Results
This result can then be saved as a table by clicking on `Save Results` in the user interface. 

#### Create Table
To create the table in one statement, simple append the required DDL to the beginning of the query and use the `EXECUTE IMMEDIATE` statement on the combined query:

```sql
DECLARE query STRING;
SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project.dataset.table'));
SET query = "CREATE OR REPLACE TABLE `project.dataset.new_table` AS "||query;
EXECUTE IMMEDIATE (query);
```

Note that options and partitioning/clustering can be included here to customize the destination table properties.

#### Create View
To create a view (which makes the generated code available to edit), the syntax is identical:

```sql
DECLARE query STRING;
SET query = (SELECT `datatovalue-tools.us_west1.row_duplicate_query`('project.dataset.table'));
SET query = "CREATE OR REPLACE VIEW `project.dataset.new_table` AS "||query;
EXECUTE IMMEDIATE (query);
```