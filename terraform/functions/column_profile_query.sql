"""((WITH
get_columns AS (
  SELECT *
  FROM `"""||SPLIT(table_id, ".")[SAFE_OFFSET(0)]||"""."""||SPLIT(table_id, ".")[SAFE_OFFSET(1)]||"""`.INFORMATION_SCHEMA.COLUMNS
  WHERE table_catalog||'.'||table_schema||'.'||table_name = '"""||table_id||"""'),

build_row_queries AS (
  SELECT *,
  ARRAY_TO_STRING([
    "SELECT",
    FORMAT("'%s.%s.%s' AS table_id,", table_catalog, table_schema, table_name),
    FORMAT("'%s' AS column_name,", column_name),
    FORMAT("%i AS ordinal_position,", ordinal_position),
    FORMAT("'%s' AS data_type,", data_type),
    "COUNT(*) AS records,",
    FORMAT("COUNTIF(%s IS NULL) AS null_records,", column_name),
    FORMAT("ROUND(100*SAFE_DIVIDE(COUNTIF(%s IS NULL),", column_name),
    "COUNT(*)), 2) AS null_percentage,",
    FORMAT("SAFE_CAST(MIN(%s) AS STRING) AS min_value,", column_name),
    FORMAT("SAFE_CAST(MAX(%s) AS STRING) AS max_value,", column_name),
    FORMAT("FROM `%s.%s.%s` AS table_id", table_catalog, table_schema, table_name)
    ], " ") AS row_query
  FROM get_columns),

build_aggregated_query AS (
  SELECT STRING_AGG(row_query, " UNION ALL\\n")||"\\nORDER BY table_id, ordinal_position"
  FROM build_row_queries)

SELECT *
FROM build_aggregated_query))
"""