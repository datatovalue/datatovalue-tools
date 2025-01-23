((WITH
get_x_datasets AS (
  SELECT x_datasets),

x_dataset_ids AS (
  SELECT "x" AS dataset_group, x_datasets.project_id||'.'||dataset_name AS dataset_id
  FROM get_x_datasets LEFT JOIN UNNEST (x_datasets.dataset_names) AS dataset_name),

get_y_datasets AS (
  SELECT y_datasets),

y_dataset_ids AS (
  SELECT "y" AS dataset_group, y_datasets.project_id||'.'||dataset_name AS dataset_id
  FROM get_y_datasets LEFT JOIN UNNEST (y_datasets.dataset_names) AS dataset_name),

all_dataset_ids AS (
  SELECT * FROM x_dataset_ids UNION ALL
  SELECT * FROM y_dataset_ids
  ),

get_information_schema_columns AS (
  SELECT table_catalog||'.'||table_schema||'.'||table_name AS table_id, table_catalog||'.'||table_schema AS dataset_id, *
  FROM `region-eu`.INFORMATION_SCHEMA.COLUMNS),

compute_column_counts AS (
  SELECT table_id, MAX(ordinal_position) AS column_count
  FROM get_information_schema_columns
  WHERE (dataset_id IN (SELECT dataset_id FROM x_dataset_ids)
  OR dataset_id IN (SELECT dataset_id FROM y_dataset_ids))
  AND table_id NOT IN (SELECT table_id FROM UNNEST(exclude_table_ids) AS table_id)
  GROUP BY dataset_id, table_id),

get_information_schema_tables AS (
  SELECT table_catalog||'.'||table_schema AS dataset_id, table_catalog||'.'||table_schema||'.'||table_name AS table_id, *
  FROM `region-eu`.INFORMATION_SCHEMA.TABLES),

join_in_metadata AS (
  SELECT *
  FROM get_information_schema_tables
  LEFT JOIN compute_column_counts USING (table_id)
  LEFT JOIN all_dataset_ids using (dataset_id)
  WHERE dataset_id IN (SELECT dataset_id FROM all_dataset_ids)),

build_query_rows AS (
  SELECT table_id, FORMAT(
    "SELECT '%s' AS dataset_group, '%s' AS table_id, '%s' AS dataset_name, '%s' AS table_name,'%s' AS table_type, %d AS column_count, COUNT(*) AS records FROM `%s`", 
    dataset_group, table_id, table_schema, table_name, table_type, column_count, table_id) AS row_query
  FROM join_in_metadata),

aggregate_base_query AS (
  SELECT 
  STRING_AGG("("||row_query||")", " UNION ALL\n") AS query
  FROM build_query_rows),

build_final_query AS (
SELECT FORMAT("""WITH
get_table_shapes AS (
%s),

filter_for_x_tables AS (
  SELECT 
  STRUCT (dataset_name, table_name, table_type, column_count, records AS row_count) AS x
  FROM get_table_shapes
  WHERE dataset_group = 'x'),

filter_for_y_tables AS (
  SELECT 
  STRUCT (dataset_name, table_name, table_type, column_count, records AS row_count) AS y
  FROM get_table_shapes
  WHERE dataset_group = 'y'),

join_x_and_y_tables AS (
  SELECT COALESCE (filter_for_x_tables.x.table_name,filter_for_y_tables.y.table_name ) AS table_name, *
  FROM filter_for_x_tables
  INNER JOIN filter_for_y_tables
  ON filter_for_x_tables.x.table_name = filter_for_y_tables.y.table_name),

compute_diffs AS (
  SELECT *,
  CASE WHEN x.table_type = y.table_type THEN true ELSE false END AS table_type_match,
  CASE WHEN x.column_count = y.column_count THEN true ELSE false END AS column_count_match,
  x.column_count - y.column_count AS column_count_diff,
  CASE WHEN x.row_count = y.row_count THEN true ELSE false END AS row_count_match,
  x.row_count - y.row_count AS row_count_diff,
  100*SAFE_DIVIDE(x.row_count - y.row_count, x.row_count) AS row_count_diff_perc
  FROM join_x_and_y_tables)

SELECT 
CASE WHEN (table_type_match = true AND column_count_match = true AND row_count_match = true) THEN true ELSE false END AS match, *
FROM compute_diffs
ORDER BY x.dataset_name, table_name
""", 
(SELECT query FROM aggregate_base_query)))

SELECT *
FROM build_final_query
))