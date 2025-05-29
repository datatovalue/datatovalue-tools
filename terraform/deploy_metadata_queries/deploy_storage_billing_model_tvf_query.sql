((
SELECT ARRAY_TO_STRING([
'CREATE OR REPLACE TABLE FUNCTION',
'`'||JSON_VALUE(options, "$.monitor_dataset_id")||'.storage_billing_model`()',
'OPTIONS (description="datatovalue-tools: storage_billing_model table function v${release_version}")',
'AS ((',
(SELECT `datatovalue-tools.${region}.storage_billing_model_query`(options)),
'))'
], "\n")
))