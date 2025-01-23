(WITH
source_query AS (
  SELECT 
  STRING_AGG(FORMAT("SELECT * FROM `%s`.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS", dataset_id), " UNION ALL\n") AS query 
  FROM UNNEST(dataset_ids) AS dataset_id),

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