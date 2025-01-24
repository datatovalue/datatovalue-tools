(WITH 
get_source_json AS (
  SELECT table_storage_json AS source_json
  ),

parse_source_json AS (
  SELECT
  JSON_VALUE(row, "$.project_number") AS project_number,
  JSON_VALUE(row, "$.table_schema") AS project_id,
  JSON_VALUE(row, "$.table_schema") AS dataset_name,
  JSON_VALUE(row, "$.table_name") AS table_name,
  SAFE_CAST(JSON_VALUE(row, "$.creation_time") AS TIMESTAMP) AS creation_time,
  SAFE_CAST(JSON_VALUE(row, "$.total_rows") AS INT64) AS total_rows,
  SAFE_CAST(JSON_VALUE(row, "$.total_partitions") AS INT64) AS total_partitions,
  SAFE_CAST(JSON_VALUE(row, "$.total_logical_bytes") AS INT64) AS total_logical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.active_logical_bytes") AS INT64) AS active_logical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.long_term_logical_bytes") AS INT64) AS long_term_logical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.current_physical_bytes") AS INT64) AS current_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.total_physical_bytes") AS INT64) AS total_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.active_physical_bytes") AS INT64) AS active_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.long_term_physical_bytes") AS INT64) AS long_term_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.time_travel_physical_bytes") AS INT64) AS time_travel_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.storage_last_modified_time") AS TIMESTAMP) AS storage_last_modified_time,
  SAFE_CAST(JSON_VALUE(row, "$.deleted") AS BOOL) AS deleted,
  JSON_VALUE(row, "$.table_type") AS table_type,
  SAFE_CAST(JSON_VALUE(row, "$.fail_safe_physical_bytes") AS INT64) AS fail_safe_physical_bytes,
  SAFE_CAST(JSON_VALUE(row, "$.last_metadata_index_refresh_time") AS TIMESTAMP) AS last_metadata_index_refresh_time  
  FROM get_source_json
  LEFT JOIN UNNEST(JSON_QUERY_ARRAY(source_json)) AS row),

  add_additional_columns AS (
    SELECT project_id||'.'||dataset_name||'.'||table_name AS table_id,
    *,
    SAFE_DIVIDE(total_logical_bytes, POW(1024,3)) AS total_logical_gib,
    SAFE_DIVIDE(active_logical_bytes, POW(1024,3)) AS active_logical_gib,
    SAFE_DIVIDE(long_term_logical_bytes, POW(1024,3)) AS long_term_logical_gib,
    SAFE_DIVIDE(current_physical_bytes, POW(1024,3)) AS current_physical_gib,
    SAFE_DIVIDE(total_physical_bytes, POW(1024,3)) AS total_physical_gib,
    SAFE_DIVIDE(active_physical_bytes, POW(1024,3)) AS active_physical_gib,
    SAFE_DIVIDE(long_term_physical_bytes, POW(1024,3)) AS long_term_physical_gib,
    SAFE_DIVIDE(time_travel_physical_bytes, POW(1024,3)) AS time_travel_physical_gib,
    SAFE_DIVIDE(fail_safe_physical_bytes, POW(1024,3)) AS fail_safe_physical_gib
    FROM parse_source_json)


SELECT *
FROM add_additional_columns)