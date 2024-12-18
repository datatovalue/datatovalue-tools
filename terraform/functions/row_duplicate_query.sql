"""WITH 
nmn_final_output AS (
  SELECT * 
  FROM `"""||table_id||"""`),

add_row_ids AS (
  SELECT 
  TO_HEX(SHA256(TO_JSON_STRING(nmn_final_output))) AS row_id, *
  FROM nmn_final_output),

add_row_occurrence AS (
  SELECT *,
  ROW_NUMBER() OVER (PARTITION BY row_id) AS row_id_occurrence
  FROM add_row_ids),

add_max_row_occurrence AS (
  SELECT *,
  MAX(row_id_occurrence) OVER (PARTITION BY row_id) AS max_row_id_occurrence
  FROM add_row_occurrence),

add_duplicate_row_flag AS (
  SELECT *, 
  CASE WHEN max_row_id_occurrence > 1 THEN true ELSE false END AS duplicate_row_flag
  FROM add_max_row_occurrence)

SELECT *
FROM add_duplicate_row_flag
"""