# JSON Functions

### generate_merged_json_schema
This User-Defined Aggregate function takes one to many rows of a single column of JSON string values as an input, and outputs a BigQuery-compliant schema as a JSON string. This schema will contain _any_ path and type present in _any_ of the rows of data, resulting in a merged schema which perfectly represents all input object contents.

Argument | Data Type | Description
--- | --- | ---
`json_value` | `STRING` | Multiple rows of JSON data encoded as strings.

Note that this function is an aggregate function, which means that it can apply a computation to multiple rows and return an aggregated value. In this case we return a single string, which is the BigQuery-compliant JSON schema.

```sql 
SELECT `datatovalue-tools`.eu.generate_merged_json_schema(data) AS schema
FROM example_json_logs_table
```

The BigQuery-compliant schema definition can then be used for a variety of subsequent use-cases, such as table creation to match the precise expected inbound data, and custom JSON parser development.

### build_json_parser_body
This function takes the BigQuery-compliant JSON schema string as input, typically as an output from the `generate_merged_json_schema` function. It then outputs the precise SQL you would need to parse all identified data from JSON into BigQuery columns, including nested and complex structures. 

Argument | Data Type | Description
--- | --- | ---
`schema` | `STRING` | BigQuery-compliant JSON schema string.

```sql 
SELECT `datatovalue-tools`.eu.build_json_parser_body(schema) AS query
```
This function is actually called via the `deploy_json_parser_query` function to create custom parser functions in your destination dataset. 

### deploy_json_parser_query
This function deploys the JSON parser into a destination location of your definition.

Argument | Data Type | Description
--- | --- | ---
`json_schema` | `STRING` | BigQuery-compliant JSON schema string.
`deployed_parser_id` | `STRING` | `project.dataset.name`  of the deployed parser function.
 
```sql 
DECLARE deployment_script STRING;

SET deployment_script = (
    SELECT `datatovalue-tools.europe_north1.deploy_json_parser_query`(
        schema, 
        `project_id.dataset_id.parser_function_name`));

EXECUTE IMMEDIATE (deployment_script);
```

For an example of how to use this function in a real-world use-case, check the advanced guide on [Automated PubSub Parsing](guides/automated_pubsub_parsing.md).
