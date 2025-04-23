# JSON Functions

### generate_merged_json_schema
This User-Defined Aggregate Function (UDAF) takes one to many rows of a single column of JSON string values as an input, and outputs a BigQuery-compliant schema as a JSON string. This schema will contain _any_ path and type present in _any_ of the rows of data, resulting in a merged schema which represents _all_ observed input object contents in _all_ rows.

Argument | Data Type | Description
--- | --- | ---
`json_value` | `STRING` | Multiple rows of JSON data encoded as strings.

Note that this function is an aggregate function, which means that it applies a computation to multiple rows and return an aggregated value, in the same manner as a `SUM` or `COUNT`. In this case we return a single string - which is the BigQuery-compliant JSON schema - and assign it to the `schema` JSON string variable.

```sql
DECLARE schema STRING;

SET schema = (
 SELECT `datatovalue-tools.eu.generate_merged_json_schema`(data) AS schema
 FROM example_json_logs_table
 )
```

The BigQuery-compliant schema definition can then be used for a variety of subsequent use-cases such as development of the subsequent custom JSON parsers. It can also be used to create inbound tables which precisely match the expected inbound data structure.

### deploy_json_parser_udf_query
This function deploys the JSON parser as a User-Defined Function (UDF) into a defined destination location (`deployed_parser_id`). The UDF operates on each row of data and returns the JSON payload parsed into BigQuery data types and structures for each row.

Argument | Data Type | Description
--- | --- | ---
`json_schema` | `STRING` | BigQuery-compliant JSON schema string.
`deployed_parser_id` | `STRING` | `project.dataset.name`  of the deployed parser function.

The following example script generates the schema and then uses this schema to deploy a SQL UDF to parse the JSON into BigQuery data types and structures.
 
```sql 
DECLARE deployed_parser_id, schema, deployment_script STRING;

SET deployed_parser_id = "project_id.dataset_id.parser_function_name";

SET schema = (
 SELECT `datatovalue-tools.eu.generate_merged_json_schema`(data) AS schema
 FROM example_json_logs_table
 )

SET deployment_script = (
 SELECT `datatovalue-tools.europe_north1.deploy_json_parser_udf_query`(
  schema, 
  deployed_parser_id
  )
);

EXECUTE IMMEDIATE (deployment_script);
```

Note that by adding a `SELECT deployment_script` statement instead of the `EXECUTE IMMEDIATE (deployment_script)` statement, the `deployment_script` can be inspected and tested before execution.

### deploy_json_parser_tvf_query
This function deploys the JSON parser as a Table-Valued Function (TVF) into a defined destination location (`deployed_parser_id`). The Table-Valued Function operates on the defined source table (`source_table_id`) and column (`json_column_name`), and returns a table-like object with the parsed JSON payload for all rows, converted into BigQuery data types and structures.

Argument | Data Type | Description
--- | --- | ---
`json_schema` | `STRING` | BigQuery-compliant JSON schema string.
`deployed_parser_id` | `STRING` | `project.dataset.name` of the deployed parser function.
`source_table_id` | `STRING` | `project.dataset.name` of the source table.
`json_column_name` | `STRING` | Name of the column containing JSON data to be parsed.
 
```sql 
DECLARE source_table_id, json_column_name, parsed_event_name, deployed_parser_id, schema, deployment_script STRING;

SET source_table_id = "project_id.sgtm_monitor.sgtm_monitor_logs";
SET json_column_name = "data";
SET parsed_event_name  = "example_event_name";
SET deployed_parser_id = "project_id.dataset_id.example_event_name";

SET schema = (
 SELECT `datatovalue-tools.eu.generate_merged_json_schema`(data) AS schema
 FROM example_json_logs_table
 )

SET deployment_script = (
 SELECT `datatovalue-tools.europe_north1.deploy_json_parser_tvf_query`(
  schema, 
  deployed_parser_id,
  source_table_id,
  json_column_name
  )
);

EXECUTE IMMEDIATE (deployment_script);
```
Note that by adding a `SELECT deployment_script` statement instead of the `EXECUTE IMMEDIATE (deployment_script)` statement, the `deployment_script` can be inspected and tested before execution.

For an example of how to use this function in a real-world use-case (to separate and parse separate event types from a single, shared PubSub topic), check the advanced guide on [Automated PubSub Parsing](guides/automated_pubsub_parsing.md).
