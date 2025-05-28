(
WITH
parse_options AS (
  SELECT JSON_VALUE_ARRAY(options, "$.dataset_ids") AS dataset_ids
  ),

build_source_query AS (
  SELECT 
  STRING_AGG(FORMAT("SELECT * FROM `%s`.__TABLES__", dataset_id), " UNION ALL\n") AS source_query
  FROM parse_options
  LEFT JOIN UNNEST(dataset_ids) AS dataset_id
  ),

build_query AS (
  SELECT """WITH
tables_metadata AS (
"""||source_query||"""
),

rename_columns AS (
  SELECT 
  project_id,
  dataset_id AS dataset_name,
  table_id AS table_name, 
  project_id||'.'||dataset_id||'.'||table_id AS table_id,
  *
  EXCEPT (project_id, dataset_id, table_id)
  FROM tables_metadata
  ),

add_computations AS (
  SELECT *,
  DATE(TIMESTAMP_MILLIS(creation_time)) AS creation_date,
  TIMESTAMP_MILLIS(creation_time) AS creation_timestamp,
  DATE(TIMESTAMP_MILLIS(last_modified_time)) AS last_modified_date,
  TIMESTAMP_MILLIS(last_modified_time) AS last_modified_timestamp,
  TIMESTAMP_DIFF(TIMESTAMP_MILLIS(last_modified_time), TIMESTAMP_MILLIS(creation_time), MINUTE) AS time_between_creation_and_modification_mins,
  SAFE_DIVIDE (size_bytes, POW(1024,2)) AS size_mib,
  SAFE_DIVIDE (size_bytes, POW(1024,3)) AS size_gib,
  SAFE_DIVIDE (size_bytes, POW(1024,4)) AS size_tib
  FROM rename_columns
  ),

parse_table_suffix AS (
  SELECT *,
  SPLIT(table_name, "_")[ARRAY_LENGTH(SPLIT(table_name, "_")) - 1] AS table_suffix
  FROM add_computations
  ),

parse_date_suffix AS (
  SELECT *,
  SAFE.PARSE_DATE("%Y%m%d", table_suffix) AS date_suffix
  FROM parse_table_suffix
  ),

flag_date_shards AS (
  SELECT *,
  CASE WHEN date_suffix IS NOT NULL THEN true ELSE false END AS is_date_shard,
  CASE WHEN time_between_creation_and_modification_mins > 0 THEN true ELSE false END AS is_modified,
  FROM parse_date_suffix
  ),

filter_for_valid_date_shards AS (
  SELECT *
  FROM flag_date_shards
  WHERE is_date_shard IS true
  ),

parse_date_prefix AS (
  SELECT *,
  RTRIM(table_name, "_"||table_suffix) AS table_prefix
  FROM filter_for_valid_date_shards
  ),

compute_days_since_creation AS (
  SELECT *,
  SAFE_DIVIDE(TIMESTAMP_DIFF(CURRENT_TIMESTAMP, creation_timestamp, MINUTE), 24 * 60) AS days_since_creation,
  FROM parse_date_prefix
  ),

compute_storage_class_days_by_shard AS (
  SELECT *,
  CASE WHEN days_since_creation >= 90 THEN 90 ELSE days_since_creation END AS active_storage_days,
  CASE WHEN days_since_creation < 90 THEN 0 ELSE days_since_creation - 90 END AS long_term_storage_days,
  FROM compute_days_since_creation
  ),

compute_gib_days_by_shard AS (
  SELECT *,
  size_gib * active_storage_days AS active_storage_gib_days,
  size_gib * long_term_storage_days AS long_term_storage_gib_days,
  FROM compute_storage_class_days_by_shard
  ),

add_per_gib_day_rates AS (
  SELECT *,
  (0.02 / 30.4375) AS active_cost_per_gib_day_usd,
  (0.01 / 30.4375) AS long_term_cost_per_gib_day_usd
  FROM compute_gib_days_by_shard
  ),

compute_total_cost_estimates_by_storage_class AS (
  SELECT *,
  active_storage_gib_days * active_cost_per_gib_day_usd AS estimated_active_storage_cost_usd,
  long_term_storage_gib_days * long_term_cost_per_gib_day_usd AS estimated_long_term_storage_cost_usd
  FROM add_per_gib_day_rates
  ),

compute_total_cost_estimates AS (
  SELECT *,
  estimated_active_storage_cost_usd + estimated_long_term_storage_cost_usd AS total_estimated_storage_cost_usd
  FROM compute_total_cost_estimates_by_storage_class
  )


SELECT *
FROM compute_total_cost_estimates
""" AS query
FROM build_source_query) 


SELECT *
FROM build_query
)