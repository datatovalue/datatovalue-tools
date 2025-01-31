(WITH
get_source_json AS (
  SELECT table_shape_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.project_id")||'.'||JSON_VALUE(row, "$.dataset_name")||'.'||JSON_VALUE(row, "$.table_name") as table_id,
  JSON_VALUE(row, "$.project_id") AS project_id,
  JSON_VALUE(row, "$.dataset_name") AS dataset_name,
  JSON_VALUE(row, "$.table_name") AS table_name,
  SAFE_CAST(JSON_VALUE(row, "$.shape.column_count") AS INT64) AS column_count,
  SAFE_CAST(JSON_VALUE(row, "$.shape.row_count") AS INT64) AS row_count
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row)

SELECT *
FROM parse_source_json)