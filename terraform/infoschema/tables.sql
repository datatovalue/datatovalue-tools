(WITH
get_source_json AS (
  SELECT tables_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.table_catalog")||'.'||JSON_VALUE(row, "$.table_schema")||'.'||JSON_VALUE(row, "$.table_name") as table_id,
  JSON_VALUE(row, "$.table_catalog") AS project_id,
  JSON_VALUE(row, "$.table_schema") AS dataset_name,
  JSON_VALUE(row, "$.table_name") AS table_name,
  JSON_VALUE(row, "$.table_type") AS table_type,
  JSON_VALUE(row, "$.is_insertable_into") AS is_insertable_into,
  JSON_VALUE(row, "$.is_typed") AS is_typed,
  JSON_VALUE(row, "$.creation_time") AS creation_time,
  JSON_VALUE(row, "$.base_table_catalog") AS base_table_catalog,
  JSON_VALUE(row, "$.base_table_schema") AS base_table_schema,
  JSON_VALUE(row, "$.base_table_name") AS base_table_name,
  JSON_VALUE(row, "$.snapshot_time_ms") AS snapshot_time_ms,
  JSON_VALUE(row, "$.ddl") AS ddl,
  JSON_VALUE(row, "$.default_collation_name") AS default_collation_name,
  JSON_VALUE(row, "$.upsert_stream_apply_watermark") AS upsert_stream_apply_watermark,
  JSON_VALUE(row, "$.replica_source_catalog") AS replica_source_catalog,
  JSON_VALUE(row, "$.replica_source_schema") AS replica_source_schema,
  JSON_VALUE(row, "$.replica_source_name") AS replica_source_name,
  JSON_VALUE(row, "$.replication_status") AS replication_status,
  JSON_VALUE(row, "$.replication_error") AS replication_error,
  JSON_VALUE(row, "$.is_change_history_enabled") AS is_change_history_enabled,
  STRUCT(
    JSON_QUERY(row, "$.sync_status.last_completion_time") AS last_completion_time,
    JSON_QUERY(row, "$.sync_status.error_time") AS error_time,
    STRUCT(
      JSON_QUERY(row, "$.sync_status.error.reason") AS error_reason,
      JSON_QUERY(row, "$.sync_status.error.location") AS error_location,
      JSON_QUERY(row, "$.sync_status.error.message") AS error_message
      ) AS error
    ) AS sync_status
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row)

SELECT *
FROM parse_source_json)