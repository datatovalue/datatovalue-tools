(WITH
get_source_json AS (
  SELECT dependencies_json),

parse_dependencies AS (
  SELECT 
  JSON_VALUE(dependency, "$.dependency_id") AS dependency_id,
  JSON_VALUE(dependency, "$.table_id") AS table_id
  FROM get_source_json
  LEFT JOIN UNNEST(JSON_QUERY_ARRAY(dependencies_json)) AS dependency)

SELECT *
FROM parse_dependencies)