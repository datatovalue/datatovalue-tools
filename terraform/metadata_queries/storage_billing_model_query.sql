(
"""WITH
datasets AS (
  SELECT 
  catalog_name||'.'||schema_name AS dataset_id,
  catalog_name AS project_id,
  schema_name AS dataset_name, 
  location
  FROM `"""||JSON_VALUE(options, "$.project_id")||"""`.INFORMATION_SCHEMA.SCHEMATA
  ORDER BY dataset_name 
  ),

identify_storage_billing_model AS (
  SELECT
  catalog_name||'.'||schema_name AS dataset_id,
  option_value AS storage_billing_model,
  'SCHEMATA_OPTIONS' AS storage_billing_model_origin
  FROM `"""||JSON_VALUE(options, "$.project_id")||"""`.INFORMATION_SCHEMA.SCHEMATA_OPTIONS
  WHERE option_name = "storage_billing_model"
  ),

join_storage_billing_model_to_datasets AS (
  SELECT *
  FROM datasets
  LEFT JOIN identify_storage_billing_model
  USING(dataset_id)
  ),

add_defaults AS (
  SELECT *
  REPLACE(
  IFNULL(storage_billing_model, "LOGICAL") AS storage_billing_model,
  IFNULL(storage_billing_model, "DEFAULT") AS storage_billing_model_origin
  )
  FROM join_storage_billing_model_to_datasets
  ),

table_storage AS (
  SELECT *
  FROM `"""||JSON_VALUE(options, "$.project_id")||""".region-${region}`.INFORMATION_SCHEMA.TABLE_STORAGE
  ),

aggregate_bytes_to_dataset AS (
  SELECT 
  project_id||'.'||table_schema AS dataset_id,
  SUM(active_logical_bytes) AS active_logical_bytes,
  SUM(long_term_logical_bytes) AS long_term_logical_bytes,
  SUM(active_physical_bytes) AS active_physical_bytes,
  SUM(long_term_physical_bytes) AS long_term_physical_bytes
  FROM table_storage
  GROUP BY dataset_id
  ),

add_gib_columns AS (
  SELECT *,
  SAFE_DIVIDE(active_logical_bytes, POW(1024, 3)) AS active_logical_gib,
  SAFE_DIVIDE(long_term_logical_bytes, POW(1024, 3)) AS long_term_logical_gib,
  SAFE_DIVIDE(active_physical_bytes, POW(1024, 3)) AS active_physical_gib,
  SAFE_DIVIDE(long_term_physical_bytes, POW(1024, 3)) AS long_term_physical_gib
  FROM aggregate_bytes_to_dataset
  ),

add_unit_costs AS (
  SELECT *,
  0.02 AS active_logical_cost_per_gib_month_usd,
  0.01 AS long_term_logical_cost_per_gib_month_usd,
  0.04 AS active_physical_cost_per_gib_month_usd,
  0.02 AS long_term_physical_cost_per_gib_month_usd
  FROM add_gib_columns
  ),

compute_monthly_cost_by_class AS (
  SELECT *,
  active_logical_gib * active_logical_cost_per_gib_month_usd AS active_logical_cost_per_month_usd,
  long_term_logical_gib * long_term_logical_cost_per_gib_month_usd AS long_term_logical_cost_per_month_usd,
  active_physical_gib * active_physical_cost_per_gib_month_usd AS active_physical_cost_per_month_usd,
  long_term_physical_gib * long_term_physical_cost_per_gib_month_usd AS long_term_physical_cost_per_month_usd
  FROM add_unit_costs
  ),

join_cost_estimates AS (
  SELECT *,
  FROM add_defaults
  LEFT JOIN compute_monthly_cost_by_class
  USING (dataset_id)
  ),

determine_actual_cost_based_on_storage_billing_model AS (
  SELECT *,
    CASE 
    WHEN storage_billing_model = 'LOGICAL' THEN active_logical_cost_per_month_usd 
    WHEN storage_billing_model = 'PHYSICAL' THEN active_physical_cost_per_month_usd 
    END AS active_cost_per_month_usd,
  CASE 
    WHEN storage_billing_model = 'LOGICAL' THEN long_term_logical_cost_per_month_usd 
    WHEN storage_billing_model = 'PHYSICAL' THEN long_term_physical_cost_per_month_usd 
    END AS long_term_cost_per_month_usd,
    CASE 
    WHEN storage_billing_model = 'LOGICAL' THEN active_logical_cost_per_month_usd + long_term_logical_cost_per_month_usd 
    WHEN storage_billing_model = 'PHYSICAL' THEN active_physical_cost_per_month_usd + long_term_physical_cost_per_month_usd 
    END AS total_cost_per_month_usd
  FROM join_cost_estimates
  ),

determine_recommended_billing_model AS (
  SELECT *,
  CASE WHEN active_logical_cost_per_month_usd < active_physical_cost_per_month_usd 
    THEN "LOGICAL" ELSE "PHYSICAL" END AS recommended_active_billing_model,
  CASE WHEN long_term_logical_cost_per_month_usd < long_term_physical_cost_per_month_usd 
    THEN "LOGICAL" ELSE "PHYSICAL" END AS recommended_long_term_billing_model,
  CASE WHEN (active_logical_cost_per_month_usd + long_term_logical_cost_per_month_usd) < (active_physical_cost_per_month_usd + long_term_physical_cost_per_month_usd)
    THEN "LOGICAL" ELSE "PHYSICAL" END AS recommended_billing_model
  FROM determine_actual_cost_based_on_storage_billing_model
  ),

forecast_cost_for_new_model AS (
  SELECT *,
  CASE WHEN storage_billing_model != recommended_billing_model 
   THEN true ELSE false END AS recommended_billing_model_change,
  CASE 
    WHEN recommended_billing_model = "LOGICAL" THEN active_logical_cost_per_month_usd 
    WHEN recommended_billing_model = "PHYSICAL" THEN active_physical_cost_per_month_usd
  END AS future_active_cost_per_month_usd,
  CASE 
    WHEN recommended_billing_model = "LOGICAL" THEN long_term_logical_cost_per_month_usd 
    WHEN recommended_billing_model = "PHYSICAL" THEN long_term_physical_cost_per_month_usd
  END AS future_long_term_cost_per_month_usd,
  CASE 
    WHEN recommended_billing_model = "LOGICAL" THEN active_logical_cost_per_month_usd + long_term_logical_cost_per_month_usd
    WHEN recommended_billing_model = "PHYSICAL" THEN active_physical_cost_per_month_usd + long_term_physical_cost_per_month_usd
  END AS future_total_cost_per_month_usd,
  FROM determine_recommended_billing_model
  ),

compute_cost_savings AS (
  SELECT *,
  total_cost_per_month_usd - future_total_cost_per_month_usd AS cost_savings_per_month_usd,
  12 * (total_cost_per_month_usd - future_total_cost_per_month_usd) AS cost_savings_per_year_usd
  FROM forecast_cost_for_new_model
  )


SELECT *
FROM compute_cost_savings"""
)

