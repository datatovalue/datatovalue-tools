(WITH
source_query AS (
  SELECT 
  FORMAT("SELECT * FROM `region-%s`.INFORMATION_SCHEMA.SCHEMATA", region) AS query),

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