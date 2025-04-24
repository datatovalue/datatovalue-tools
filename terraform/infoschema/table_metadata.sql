(WITH
get_source_json AS (
  SELECT table_metadata_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.project_id")||'.'||JSON_VALUE(row, "$.dataset_id")||'.'||JSON_VALUE(row, "$.table_id") as table_id,
  JSON_VALUE(row, "$.project_id") AS project_id,
  JSON_VALUE(row, "$.dataset_id") AS dataset_name,
  JSON_VALUE(row, "$.table_id") AS table_name,
  SAFE_CAST(JSON_VALUE(row, "$.creation_time") AS INT64) AS creation_time,
  SAFE_CAST(JSON_VALUE(row, "$.last_modified_time") AS INT64) AS last_modified_time,
  SAFE_CAST(JSON_VALUE(row, "$.row_count") AS INT64) AS row_count,
  SAFE_CAST(JSON_VALUE(row, "$.size_bytes") AS INT64) AS size_bytes,
  JSON_VALUE(row, "$.type") AS type
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row),

add_additional_fields AS (
  SELECT *,
  TIMESTAMP_MILLIS(creation_time) AS creation_timestamp,
  TIMESTAMP_MILLIS(last_modified_time) AS last_modified_timestamp,
  SAFE_DIVIDE(size_bytes, POW(1024, 3)) AS size_gib,
  SAFE_DIVIDE(size_bytes, POW(1024, 4)) AS size_tib
  FROM parse_source_json)


SELECT *
FROM add_additional_fields)