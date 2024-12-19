((WITH 
build_information_schema_union_query AS (
  SELECT 
  STRING_AGG(
    FORMAT("SELECT * FROM `%s.%s`.INFORMATION_SCHEMA.PARTITIONS", 
    project_id, dataset_name)
  , "  UNION ALL\n") AS information_schema_union_query
  FROM UNNEST (dataset_names) AS dataset_name
  ORDER BY information_schema_union_query ASC
),

build_query AS (
SELECT 
"""WITH
information_schema_partitions AS (
"""||(SELECT information_schema_union_query FROM build_information_schema_union_query)||"""
),

parse_information_schema AS (
  SELECT 
  table_catalog||'.'||table_schema||'.'||table_name AS table_id,
  table_schema AS dataset_name,
  SAFE.PARSE_DATE("%Y%m%d", partition_id) AS partition_date
  ,* 
  FROM information_schema_partitions
  ),

filter_out_nulls AS (
  SELECT * 
  FROM parse_information_schema
  WHERE partition_date IS NOT NULL
  ),

aggregate_to_table_id AS (
  SELECT 
  dataset_name, table_name,
  MIN(partition_date) AS min_partition_date,
  MAX(partition_date) AS max_partition_date,
  DATE_DIFF(MAX(partition_date), MIN(partition_date), DAY) + 1 AS partition_date_range_days,
  COUNT(DISTINCT partition_date) AS partition_date_count,
  ARRAY_AGG(DISTINCT partition_date ORDER BY partition_date DESC) AS partition_dates,
  GENERATE_DATE_ARRAY(MIN(partition_date), MAX(partition_date), INTERVAL 1 DAY) AS partition_date_range_dates
  FROM filter_out_nulls
  GROUP BY ALL
  ),

compute_partition_date_coverage AS (
  SELECT *,
  ROUND(100*SAFE_DIVIDE(partition_date_count, partition_date_range_days), 3) AS partition_date_coverage_perc
  FROM aggregate_to_table_id
  ),

identify_missing_dates AS (
  SELECT 
  dataset_name, table_name, 
  ARRAY_AGG(partition_date_range_date ORDER BY partition_date_range_date DESC) AS missing_date_partitions
  FROM compute_partition_date_coverage
  LEFT JOIN UNNEST (partition_date_range_dates) AS partition_date_range_date
  LEFT JOIN UNNEST (partition_dates) AS partition_date ON partition_date_range_date = partition_date
  WHERE partition_date IS NULL
  GROUP BY ALL
  ),

join_missing_partitions AS (
  SELECT *
  FROM compute_partition_date_coverage 
  LEFT JOIN identify_missing_dates
  USING (dataset_name, table_name)
  ),

prepare_output AS (
  SELECT *
  EXCEPT(partition_dates, partition_date_range_dates)
  FROM join_missing_partitions
  ORDER BY dataset_name, table_name
  )
  
SELECT * 
FROM prepare_output""" AS query
)

SELECT *
FROM build_query))