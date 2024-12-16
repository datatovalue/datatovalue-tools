# datatovalue-tools

## Data Quality Assurance Functions
Data Quality Assurance functions are utility functions to support data profiling, debugging and root-cause analysis in data transformations.

### Deployment

Functions are deployed across in the `datatovalue-tools` BigQuery project all global regions, including `eu` and `us` multi-regions. Deployment regions are set via the `regions` variable in the [terraform.tfvars](https://github.com/datatovalue/datatovalue-tools/blob/main/terraform/terraform.tfvars) file and align to the datasets in the `datatovalue-tools` BigQuery project. Note that the dataset names replace dashes with underscores (e.g. `us-west1` corresponds to the `us_west1` dataset).

### Usage
Functions take parameters and return SQL, which can be executed in order to obtain the desired result set. The following actions are achieved via the this set of approaches:

Action | Approach
--- | ---
View SQL | Invoke function via SELECT statement
Execute SQL | EXECUTE IMMEDIATE function
Save Result | 'Save Result' from executed SQL via the user interface
Create View | Append DDL prefix and EXECUTE IMMEDIATE
Create Table | Append DDL prefix and EXECUTE IMMEDIATE

### Functions
#### row_duplicate_query

Name | Objective
--- | ---
row_duplicate_query | Identify duplicate rows in any table

#### unique_combination_query

Name | Objective
--- | ---
unique_combination_query | Validate whether combinations of columns are unique in any table


