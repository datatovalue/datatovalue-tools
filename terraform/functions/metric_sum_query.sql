(("""WITH
all_numeric_columns AS (
  SELECT 
  table_schema||'.'||table_name AS model_id, *
  FROM `"""||project_id||""".region-"""||REPLACE(IFNULL(region, 'eu'), "_", "-")||"""`.INFORMATION_SCHEMA.COLUMNS
  WHERE data_type IN ('INT64', 'FLOAT64', 'NUMERIC', 'BIGNUMERIC')
  ),

dataset_filter AS (
  SELECT *
  FROM all_numeric_columns
  WHERE table_schema LIKE ANY ('"""||ARRAY_TO_STRING(dataset_names, "', '")||"""')
  ORDER BY model_id
  ),

column_filter AS (
  SELECT *
  FROM dataset_filter
  WHERE column_name IN ('"""||IFNULL(ARRAY_TO_STRING(column_names, "', '"), "")||"""')
  ORDER BY model_id
  ),

build_row_queries_prev AS (
  SELECT *, 
  FORMAT("SELECT '%s' AS model_id, '%s' AS metric, '%s' AS data_type, ROUND(SUM(SAFE_CAST(%s AS FLOAT64)), %d) AS value FROM `%s`",
  model_id, column_name, data_type, column_name, """||rounding_digits||""", model_id) AS row_query
  FROM """||
    CASE 
    WHEN IFNULL(ARRAY_LENGTH(column_names), 0) > 1 THEN "column_filter" 
    ELSE "dataset_filter" END||"""
  ),

build_row_queries AS (
  SELECT *, 
  FORMAT("SELECT '%s' AS metric, ROUND(SUM(SAFE_CAST(%s AS FLOAT64)), %d) AS value, '%s' AS model_id, '%s' AS data_type FROM `%s`",
  column_name, column_name, """||rounding_digits||""", model_id, data_type, model_id) AS row_query
  FROM """||
    CASE 
    WHEN IFNULL(ARRAY_LENGTH(column_names), 0) > 1 THEN "column_filter" 
    ELSE "dataset_filter" END||"""
  ),


build_query AS (
  SELECT 
  STRING_AGG(row_query, " UNION ALL\\n")||"\\n\\nORDER BY metric ASC, model_id ASC"
  FROM build_row_queries
  )


SELECT *
FROM build_query
"""))