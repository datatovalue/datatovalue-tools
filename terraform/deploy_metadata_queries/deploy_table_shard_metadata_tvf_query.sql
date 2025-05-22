((
SELECT ARRAY_TO_STRING([
'CREATE OR REPLACE TABLE FUNCTION',
'`'||JSON_VALUE(options, "$.monitor_dataset_id")||'.table_shard_metadata`()',
'OPTIONS (description="datatovalue-tools: table_shard_metadata table function v${release_version}")',
'AS ((',
(SELECT `datatovalue-tools.${region}.table_shard_metadata_query`(options)),
'))'
], "\n")
))