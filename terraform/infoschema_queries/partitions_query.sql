(WITH
parse_inputs AS (
  SELECT 
  table_id,
  SPLIT(table_id, ".")[SAFE_OFFSET(0)] AS project_id,
  SPLIT(table_id, ".")[SAFE_OFFSET(1)] AS dataset_name,
  SPLIT(table_id, ".")[SAFE_OFFSET(0)]||'.'||SPLIT(table_id, ".")[SAFE_OFFSET(1)] AS dataset_id,
  SPLIT(table_id, ".")[SAFE_OFFSET(2)] AS table_name
  FROM UNNEST(table_ids) AS table_id),

filter_for_unique_datasets AS (
  SELECT 
  ARRAY_AGG(DISTINCT dataset_id) AS dataset_ids
  FROM parse_inputs
),

build_source_query AS (
  SELECT STRING_AGG(FORMAT("SELECT * FROM `%s`.INFORMATION_SCHEMA.PARTITIONS", dataset_id), " UNION ALL\n") AS query
  FROM filter_for_unique_datasets
  LEFT JOIN UNNEST(dataset_ids) AS dataset_id
),

base_query AS (
SELECT 
FORMAT("""WITH
information_schema AS (\n%s),

filter_tables AS (
SELECT *
FROM information_schema
WHERE table_catalog||'.'||table_schema||'.'||table_name
IN (%s)),

parse_table_options AS (
SELECT 
PARSE_JSON("["||STRING_AGG(TO_JSON_STRING(filter_tables), ",")||"]") AS response
FROM filter_tables)

SELECT *
FROM parse_table_options
  """, 
  query,
  "'"||ARRAY_TO_STRING(table_ids, "', '")||"'")
  FROM build_source_query)


SELECT *
FROM base_query)