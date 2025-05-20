(
SELECT FORMAT ("""WITH 
set_config AS (
  SELECT JSON '''"""||TO_JSON_STRING(config, true)||"""''' AS config
  ),

information_schema_tables_metadata AS (
%s
),

rename_columns AS (
  SELECT 
  project_id||'.'||dataset_id||'.'||table_id AS table_id,
  project_id,
  dataset_id AS dataset_name,
  table_id AS table_name,
  *
  EXCEPT (table_id, project_id, dataset_id)
  FROM information_schema_tables_metadata
  ),

add_additional_fields AS (
  SELECT *,
  TIMESTAMP_MILLIS(creation_time) AS creation_timestamp,
  TIMESTAMP_MILLIS(last_modified_time) AS last_modified_timestamp,
  SAFE_DIVIDE(size_bytes, POW(1024, 3)) AS size_gib,
  SAFE_DIVIDE(size_bytes, POW(1024, 4)) AS size_tib
  FROM rename_columns
  ),

compute_time_since_modified AS (
  SELECT *,
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP, last_modified_timestamp, MINUTE) AS time_since_last_modified_mins,
  SAFE_DIVIDE(TIMESTAMP_DIFF(CURRENT_TIMESTAMP, last_modified_timestamp, MINUTE), 60) AS time_since_last_modified_hrs,
  SAFE_DIVIDE(TIMESTAMP_DIFF(CURRENT_TIMESTAMP, last_modified_timestamp, MINUTE), 1440) AS time_since_last_modified_days
  FROM add_additional_fields
  ),

get_monitoring_options AS (
  SELECT 
  JSON_VALUE(table_config, "$.table_id") AS table_id,
  FLOAT64(JSON_QUERY(table_config, "$.alert_threshold_hrs")) AS alert_threshold_hrs,
  true AS has_config
  FROM set_config LEFT JOIN UNNEST(JSON_QUERY_ARRAY(config, "$.tables")) AS table_config
  ),

join_alerting_options_to_table_metadata AS (
  SELECT *
  FROM compute_time_since_modified
  LEFT JOIN get_monitoring_options USING (table_id)
  ),

set_defaults AS (
  SELECT *
  REPLACE (IFNULL(alert_threshold_hrs, %f) AS alert_threshold_hrs)
  FROM join_alerting_options_to_table_metadata
  ),

add_delayed_flag AS (
  SELECT *,
  CASE WHEN time_since_last_modified_hrs > alert_threshold_hrs THEN true ELSE false END AS is_delayed
  FROM set_defaults
  ),

add_delayed_icon AS (
  SELECT *,
  NOT (is_delayed) AS is_fresh,
  CASE WHEN is_delayed IS true THEN "⚠️" ELSE "✅" END AS status_icon
  FROM add_delayed_flag
  ),

filter_for_configs AS (
  SELECT *
  FROM add_delayed_icon
  WHERE has_config IS true
  )

SELECT *
FROM filter_for_configs""",

(SELECT STRING_AGG(DISTINCT(
"SELECT * FROM `"||
SPLIT(JSON_VALUE(table_config, "$.table_id"), ".")[SAFE_OFFSET(0)]||'.'||SPLIT(JSON_VALUE(table_config, "$.table_id"), ".")[SAFE_OFFSET(1)])||
"`.__TABLES__", " UNION ALL\n")
FROM UNNEST(JSON_QUERY_ARRAY(config, "$.tables")) AS table_config),

(IFNULL(FLOAT64(JSON_QUERY(config, "$.default_monitoring_threshold_hours")), 24))

))