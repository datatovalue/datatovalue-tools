(WITH
parse_query_options AS (
  SELECT 
  IFNULL(JSON_VALUE(query_options, "$.where_clause"), "") AS where_clause,
  IFNULL(" EXCEPT("||ARRAY_TO_STRING(JSON_VALUE_ARRAY(query_options, "$.except_columns"), ", ")||")", "") AS except_columns),

source_query AS (
  SELECT 
  FORMAT("SELECT *%s FROM `%s.region-us-west1`.INFORMATION_SCHEMA.TABLE_STORAGE \n%s", except_columns, project_id, where_clause) AS query
  FROM parse_query_options),

base_query AS (
  SELECT 
  FORMAT("""WITH\ninformation_schema AS (\n%s),

parse_information_schema AS (
SELECT 
PARSE_JSON("["||STRING_AGG(TO_JSON_STRING(information_schema), ",")||"]") AS response
FROM information_schema)

SELECT *
FROM parse_information_schema
  """, query)
  FROM source_query)


SELECT *
FROM base_query)