(WITH
get_source_json AS (
  SELECT datasets_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.catalog_name")||'.'||JSON_VALUE(row, "$.schema_name") as dataset_id,
  JSON_VALUE(row, "$.catalog_name") AS project_id,
  JSON_VALUE(row, "$.schema_name") AS dataset_name,
  JSON_VALUE(row, "$.schema_owner") AS schema_owner,
  SAFE_CAST(JSON_VALUE(row, "$.creation_time") AS TIMESTAMP) AS creation_time,
  SAFE_CAST(JSON_VALUE(row, "$.last_modified_time") AS TIMESTAMP) AS last_modified_time,
  JSON_VALUE(row, "$.location") AS location,
  JSON_VALUE(row, "$.ddl") AS ddl,
  JSON_VALUE(row, "$.default_collation_name") AS default_collation_name,
  JSON_VALUE(row, "$.sync_status") AS sync_status,
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row)

SELECT *
FROM parse_source_json)