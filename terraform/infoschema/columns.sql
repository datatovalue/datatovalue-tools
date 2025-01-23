(WITH 
get_source_json AS (
  SELECT columns_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.table_catalog")||'.'||JSON_VALUE(row, "$.table_schema")||'.'||JSON_VALUE(row, "$.table_name") AS table_id,
  JSON_VALUE(row, "$.table_catalog") AS table_catalog,
  JSON_VALUE(row, "$.table_schema") AS table_schema,
  JSON_VALUE(row, "$.table_name") AS table_name,
  JSON_VALUE(row, "$.activity_date_pacific") AS activity_date_pacific,
  JSON_VALUE(row, "$.ordinal_position") AS ordinal_position,
  JSON_VALUE(row, "$.is_nullable") AS is_nullable,
  JSON_VALUE(row, "$.data_type") AS data_type,
  JSON_VALUE(row, "$.is_generated") AS is_generated,
  JSON_VALUE(row, "$.generation_expression") AS generation_expression,
  JSON_VALUE(row, "$.is_stored") AS is_stored,
  JSON_VALUE(row, "$.is_hidden") AS is_hidden,
  JSON_VALUE(row, "$.is_updatable") AS is_updatable,
  JSON_VALUE(row, "$.is_system_defined") AS is_system_defined,
  JSON_VALUE(row, "$.is_partitioning_column") AS is_partitioning_column,
  JSON_VALUE(row, "$.clustering_ordinal_position") AS clustering_ordinal_position,
  JSON_VALUE(row, "$.collation_name") AS collation_name,
  JSON_VALUE(row, "$.column_default") AS column_default,
  JSON_VALUE(row, "$.rounding_mode") AS rounding_mode
  FROM get_source_json
  LEFT JOIN UNNEST(JSON_QUERY_ARRAY(source_json)) AS row)

SELECT *
FROM parse_source_json)