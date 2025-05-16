((
SELECT ARRAY_TO_STRING([
'CREATE OR REPLACE TABLE FUNCTION',
'`'||JSON_VALUE(config, "$.monitor_dataset_id")||'.monitor_tables`(config JSON)',
'OPTIONS (description="datatovalue-tools: monitor_tables table function v${release_version}")',
'AS ((',
(SELECT `datatovalue-tools.${region}.monitor_tables_query`(config)),
'))'
], "\n")
))