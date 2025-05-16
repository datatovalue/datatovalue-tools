((WITH
unnest_and_order_columns AS (
  SELECT * 
  FROM UNNEST(column_names) AS column
  ORDER BY column
  ),

build_query AS (
  SELECT 
  ARRAY_TO_STRING(
    [
    "SELECT",
    "'"||table_id||"' AS table_id,",
    "['"||STRING_AGG(column , "', '")||"'] AS combination,",
    SAFE_CAST(ARRAY_LENGTH(ARRAY_AGG(column)) AS STRING)||" AS combination_columns,",
    "COUNT(*) AS unique_combinations,",
    "records,",
    "ROUND(100*SAFE_DIVIDE(COUNT(*), records), 3) AS uniqueness_percentage",
    "FROM (",
    "SELECT "||STRING_AGG((column), ", ")||",",
    "(SELECT COUNT(*) FROM `"||table_id||"`) AS records",
    "FROM `"||table_id||"`",
    "GROUP BY ALL)",
    "GROUP BY ALL"
    ], "\n")
   AS query
  FROM unnest_and_order_columns)


SELECT * 
FROM build_query
))