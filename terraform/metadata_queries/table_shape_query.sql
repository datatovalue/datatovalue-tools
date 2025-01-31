(WITH
infoschema_columns AS (
  SELECT * 
  FROM `datatovalue-tools.eu`.columns(columns_json)),

count_columns AS (
  SELECT 
  table_id, project_id, dataset_name, table_name,
  MAX(ordinal_position) AS columns
  FROM infoschema_columns
  GROUP BY all),

build_source_query AS (
  SELECT 
  STRING_AGG(FORMAT ("""SELECT '%s' AS table_id, '%s' AS project_id, '%s' AS dataset_name, '%s' AS table_name, STRUCT(COUNT(*) AS row_count, %d AS column_count) AS shape FROM `%s`""", table_id, project_id, dataset_name, table_name, columns, table_id), " UNION ALL \n") AS source_query
  FROM count_columns),

build_query AS (
  SELECT FORMAT("""WITH
get_shape AS (
%s),

encode_json_response AS (
  SELECT 
  PARSE_JSON("["||STRING_AGG(TO_JSON_STRING(get_shape), ",")||"]") AS dependencies
  FROM get_shape)

SELECT *
FROM encode_json_response""", source_query) AS query
  FROM build_source_query)

SELECT *
FROM build_query)
