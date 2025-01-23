(WITH
get_source_json AS (
  SELECT column_field_paths_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.table_catalog")||'.'||JSON_VALUE(row, "$.table_schema")||'.'||JSON_VALUE(row, "$.table_name") as table_id,
  JSON_VALUE(row, "$.table_catalog") AS project_id,
  JSON_VALUE(row, "$.table_schema") AS dataset_name,
  JSON_VALUE(row, "$.table_name") AS table_name,
  JSON_VALUE(row, "$.column_name") AS column_name,
  JSON_VALUE(row, "$.field_path") AS field_path,
  JSON_VALUE(row, "$.data_type") AS data_type,
  JSON_VALUE(row, "$.description") AS description,
  JSON_VALUE(row, "$.collation_name") AS collation_name,
  JSON_VALUE(row, "$.rounding_mode") AS rounding_mode
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row)

SELECT *
FROM parse_source_json)