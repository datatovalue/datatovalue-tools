(WITH 
get_source_json AS (
  SELECT partitions_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.table_catalog")||'.'||JSON_VALUE(row, "$.table_schema")||'.'||JSON_VALUE(row, "$.table_name") AS table_id,
  JSON_VALUE(row, "$.table_catalog") AS table_catalog,
  JSON_VALUE(row, "$.table_schema") AS table_schema,
  JSON_VALUE(row, "$.table_name") AS table_name,
  SAFE_CAST(JSON_VALUE(row, "$.partition_id") AS INT64) AS partition_id,
  SAFE_CAST(JSON_VALUE(row, "$.total_rows") AS INT64) AS total_rows,
  SAFE_CAST(JSON_VALUE(row, "$.total_logical_bytes") AS INT64) AS total_logical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.total_billable_bytes") AS INT64) AS total_billable_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.last_modified_time") AS TIMESTAMP) AS last_modified_time,
  JSON_VALUE(row, "$.storage_tier") AS storage_tier
  FROM get_source_json
  LEFT JOIN UNNEST(JSON_QUERY_ARRAY(source_json)) AS row),

add_additional_fields AS (
  SELECT *,
  SAFE.PARSE_DATE("%Y%m%d", SAFE_CAST(partition_id AS STRING)) AS partition_date,
  SAFE_DIVIDE(total_logical_bytes, POW(1024,3)) AS total_logical_gib,
  SAFE_DIVIDE(total_billable_bytes, POW(1024,3)) AS total_billable_gib,
  FROM parse_source_json
)

SELECT *
FROM add_additional_fields)