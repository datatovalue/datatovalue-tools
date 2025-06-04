(
WITH
parse_labels AS (
  SELECT 
  '['||STRING_AGG(
  'STRUCT ("'||JSON_KEYS(label)[SAFE_OFFSET(0)]||'" AS key, '||RTRIM(SPLIT(TO_JSON_STRING(label), ":")[1], "}")||' AS value)'
  , ", ")||']' AS labels
  FROM UNNEST(JSON_QUERY_ARRAY(options, "$.labels")) AS label
  ),

parse_options AS (
SELECT 
  JSON_VALUE(options, "$.dataset_id") AS dataset_id,
  JSON_VALUE(options, "$.default_kms_key_name") AS default_kms_key_name,
  SAFE_CAST(JSON_VALUE(options, "$.default_partition_expiration_days") AS FLOAT64) AS default_partition_expiration_days,
  JSON_VALUE(options, "$.default_rounding_mode") AS default_rounding_mode,
  SAFE_CAST(JSON_VALUE(options, "$.default_table_expiration_days") AS INT64) AS default_table_expiration_days,
  JSON_VALUE(options, "$.description") AS description,
  JSON_VALUE(options, "$.failover_reservation") AS failover_reservation,
  JSON_VALUE(options, "$.friendly_name") AS friendly_name,
  SAFE_CAST(JSON_VALUE(options, "$.is_case_insensitive") AS BOOL) AS is_case_insensitive,
  (SELECT labels FROM parse_labels) AS labels,
  SAFE_CAST(JSON_VALUE(options, "$.max_time_travel_hours") AS INT64) AS max_time_travel_hours,
  JSON_VALUE(options, "$.primary_replica") AS primary_replica,
  JSON_VALUE(options, "$.storage_billing_model") AS storage_billing_model),

build_options AS (
  SELECT [
    CASE WHEN default_kms_key_name IS NULL THEN 'NULL' ELSE 'default_kms_key_name = "'||default_kms_key_name||'"' END,
    CASE WHEN default_partition_expiration_days IS NULL THEN 'NULL' ELSE 'default_partition_expiration_days = '||default_partition_expiration_days END,
    CASE WHEN default_rounding_mode IS NULL THEN 'NULL' ELSE 'default_rounding_mode = '||default_rounding_mode END,
    CASE WHEN default_table_expiration_days IS NULL THEN 'NULL' ELSE 'default_table_expiration_days = '||default_table_expiration_days END,
    CASE WHEN description IS NULL THEN 'NULL' ELSE 'description = "'||description||'"' END,
    CASE WHEN failover_reservation IS NULL THEN 'NULL' ELSE 'failover_reservation = "'||failover_reservation||'"' END,
    CASE WHEN friendly_name IS NULL THEN 'NULL' ELSE 'friendly_name = "'||friendly_name||'"' END,
    CASE WHEN is_case_insensitive IS NULL THEN 'NULL' ELSE 'is_case_insensitive = '||is_case_insensitive END,
    CASE WHEN labels IS NULL THEN 'NULL' ELSE 'labels = '||labels END,
    CASE WHEN max_time_travel_hours IS NULL THEN 'NULL' ELSE 'max_time_travel_hours = '||max_time_travel_hours END,
    CASE WHEN primary_replica IS NULL THEN 'NULL' ELSE 'primary_replica = "'||primary_replica||'"' END,
    CASE WHEN storage_billing_model IS NULL THEN 'NULL' ELSE 'storage_billing_model = "'||storage_billing_model||'"' END
  ] AS options_array
  FROM parse_options
),

build_options_body AS (
  SELECT 
  STRING_AGG(option, ",\n") AS options_body
  FROM build_options
  LEFT JOIN UNNEST (options_array) AS option
  WHERE option != "NULL"),

build_query AS (
  SELECT 
  ARRAY_TO_STRING ([
    "ALTER SCHEMA `"||(SELECT dataset_id FROM parse_options)||"`",
    "SET OPTIONS (",
    (SELECT options_body FROM build_options_body),
    ")"
    ], "\n")
  FROM build_options_body
  )


SELECT *
FROM build_query
)