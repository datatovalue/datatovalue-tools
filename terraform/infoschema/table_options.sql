(WITH
get_source_json AS (
  SELECT table_options_json AS source_json
  ),

parse_source_json AS (
  SELECT 
  JSON_VALUE(row, "$.table_catalog")||'.'||JSON_VALUE(row, "$.table_schema")||'.'||JSON_VALUE(row, "$.table_name") as table_id,
  JSON_VALUE(row, "$.table_catalog") AS project_id,
  JSON_VALUE(row, "$.table_schema") AS dataset_name,
  JSON_VALUE(row, "$.table_name") AS table_name,
  JSON_VALUE(row, "$.option_name") AS option_name,
  JSON_VALUE(row, "$.option_type") AS option_type,
  TRIM(JSON_VALUE(row, "$.option_value"), '"') AS option_value,
  FROM get_source_json
  LEFT JOIN 
  UNNEST(JSON_QUERY_ARRAY(source_json)) AS row),

base_table AS (
  SELECT DISTINCT table_id, project_id, dataset_name, table_name 
  FROM parse_source_json 
  ORDER BY table_id ASC),

  option_description AS (SELECT table_id, option_value AS description FROM parse_source_json WHERE option_name = "description"),
  option_enable_refresh AS (SELECT table_id, option_value AS enable_refresh FROM parse_source_json WHERE option_name = "enable_refresh"),
  option_expiration_timestamp AS (SELECT table_id, option_value AS expiration_timestamp FROM parse_source_json WHERE option_name = "expiration_timestamp"),
  option_friendly_name AS (SELECT table_id, option_value AS friendly_name FROM parse_source_json WHERE option_name = "friendly_name"),
  option_kms_key_name AS (SELECT table_id, option_value AS kms_key_name FROM parse_source_json WHERE option_name = "kms_key_name"),
  option_labels AS (SELECT table_id, option_value AS labels FROM parse_source_json WHERE option_name = "labels"),
  option_partition_expiration_days AS (SELECT table_id, option_value AS partition_expiration_days FROM parse_source_json WHERE option_name = "partition_expiration_days"),
  option_refresh_interval_minutes AS (SELECT table_id, option_value AS refresh_interval_minutes FROM parse_source_json WHERE option_name = "refresh_interval_minutes"),
  option_require_partition_filter AS (SELECT table_id, option_value AS require_partition_filter FROM parse_source_json WHERE option_name = "require_partition_filter"),
  option_tags AS (SELECT table_id, option_value AS tags FROM parse_source_json WHERE option_name = "tags"),

  -- External table options
  
  option_allow_jagged_rows AS (SELECT table_id, option_value AS allow_jagged_rows FROM parse_source_json WHERE option_name = "allow_jagged_rows"),
  option_allow_quoted_newlines AS (SELECT table_id, option_value AS allow_quoted_newlines FROM parse_source_json WHERE option_name = "allow_quoted_newlines"),
  option_bigtable_options AS (SELECT table_id, option_value AS bigtable_options FROM parse_source_json WHERE option_name = "bigtable_options"),
  option_column_name_character_map AS (SELECT table_id, option_value AS column_name_character_map FROM parse_source_json WHERE option_name = "column_name_character_map"),
  option_compression AS (SELECT table_id, option_value AS compression FROM parse_source_json WHERE option_name = "compression"),
  option_decimal_target_types AS (SELECT table_id, option_value AS decimal_target_types FROM parse_source_json WHERE option_name = "decimal_target_types"),
  option_enable_list_inference AS (SELECT table_id, option_value AS enable_list_inference FROM parse_source_json WHERE option_name = "enable_list_inference"),
  option_enable_logical_types AS (SELECT table_id, option_value AS enable_logical_types FROM parse_source_json WHERE option_name = "enable_logical_types"),
  option_encoding AS (SELECT table_id, option_value AS encoding FROM parse_source_json WHERE option_name = "encoding"),
  option_enum_as_string AS (SELECT table_id, option_value AS enum_as_string FROM parse_source_json WHERE option_name = "enum_as_string"),
  option_field_delimiter AS (SELECT table_id, option_value AS field_delimiter FROM parse_source_json WHERE option_name = "field_delimiter"),
  option_format AS (SELECT table_id, option_value AS format FROM parse_source_json WHERE option_name = "format"),
  option_hive_partition_uri_prefix AS (SELECT table_id, option_value AS hive_partition_uri_prefix FROM parse_source_json WHERE option_name = "hive_partition_uri_prefix"),
  option_file_set_spec_type AS (SELECT table_id, option_value AS file_set_spec_type FROM parse_source_json WHERE option_name = "file_set_spec_type"),
  option_ignore_unknown_values AS (SELECT table_id, option_value AS ignore_unknown_values FROM parse_source_json WHERE option_name = "ignore_unknown_values"),
  option_json_extension AS (SELECT table_id, option_value AS json_extension FROM parse_source_json WHERE option_name = "json_extension"),
  option_max_bad_records AS (SELECT table_id, option_value AS max_bad_records FROM parse_source_json WHERE option_name = "max_bad_records"),
  option_max_staleness AS (SELECT table_id, option_value AS max_staleness FROM parse_source_json WHERE option_name = "max_staleness"),
  option_null_marker AS (SELECT table_id, option_value AS null_marker FROM parse_source_json WHERE option_name = "null_marker"),
  option_object_metadata AS (SELECT table_id, option_value AS object_metadata FROM parse_source_json WHERE option_name = "object_metadata"),
  option_preserve_ascii_control_characters AS (SELECT table_id, option_value AS preserve_ascii_control_characters FROM parse_source_json WHERE option_name = "preserve_ascii_control_characters"),
  option_projection_fields AS (SELECT table_id, option_value AS projection_fields FROM parse_source_json WHERE option_name = "projection_fields"),
  option_quote AS (SELECT table_id, option_value AS quote FROM parse_source_json WHERE option_name = "quote"),
  option_reference_file_schema_uri AS (SELECT table_id, option_value AS reference_file_schema_uri FROM parse_source_json WHERE option_name = "reference_file_schema_uri"),
  option_require_hive_partition_filter AS (SELECT table_id, option_value AS require_hive_partition_filter FROM parse_source_json WHERE option_name = "require_hive_partition_filter"),
  option_sheet_range AS (SELECT table_id, option_value AS sheet_range FROM parse_source_json WHERE option_name = "sheet_range"),
  option_skip_leading_rows AS (SELECT table_id, option_value AS skip_leading_rows FROM parse_source_json WHERE option_name = "skip_leading_rows"),
  option_uris AS (SELECT table_id, option_value AS uris FROM parse_source_json WHERE option_name = "uris"),

join_options_as_columns AS (
  SELECT * 
  FROM base_table
  LEFT JOIN option_description USING (table_id)
  LEFT JOIN option_enable_refresh USING (table_id)
  LEFT JOIN option_expiration_timestamp USING (table_id)
  LEFT JOIN option_friendly_name USING (table_id)
  LEFT JOIN option_kms_key_name USING (table_id)
  LEFT JOIN option_labels USING (table_id)
  LEFT JOIN option_partition_expiration_days USING (table_id)
  LEFT JOIN option_refresh_interval_minutes USING (table_id)
  LEFT JOIN option_require_partition_filter USING (table_id)
  LEFT JOIN option_tags USING (table_id)
  LEFT JOIN option_allow_jagged_rows USING (table_id)
  LEFT JOIN option_allow_quoted_newlines USING (table_id)
  LEFT JOIN option_bigtable_options USING (table_id)
  LEFT JOIN option_column_name_character_map USING (table_id)
  LEFT JOIN option_compression USING (table_id)
  LEFT JOIN option_decimal_target_types USING (table_id)
  LEFT JOIN option_enable_list_inference USING (table_id)
  LEFT JOIN option_enable_logical_types USING (table_id)
  LEFT JOIN option_encoding USING (table_id)
  LEFT JOIN option_enum_as_string USING (table_id)
  LEFT JOIN option_field_delimiter USING (table_id)
  LEFT JOIN option_format USING (table_id)
  LEFT JOIN option_hive_partition_uri_prefix USING (table_id)
  LEFT JOIN option_file_set_spec_type USING (table_id)
  LEFT JOIN option_ignore_unknown_values USING (table_id)
  LEFT JOIN option_json_extension USING (table_id)
  LEFT JOIN option_max_bad_records USING (table_id)
  LEFT JOIN option_max_staleness USING (table_id)
  LEFT JOIN option_null_marker USING (table_id)
  LEFT JOIN option_object_metadata USING (table_id)
  LEFT JOIN option_preserve_ascii_control_characters USING (table_id)
  LEFT JOIN option_projection_fields USING (table_id)
  LEFT JOIN option_quote USING (table_id)
  LEFT JOIN option_reference_file_schema_uri USING (table_id)
  LEFT JOIN option_require_hive_partition_filter USING (table_id)
  LEFT JOIN option_sheet_range USING (table_id)
  LEFT JOIN option_skip_leading_rows USING (table_id)
  LEFT JOIN option_uris USING (table_id)
  ),

  parse_uris AS (
    SELECT *
    REPLACE (JSON_VALUE_ARRAY(PARSE_JSON(uris)) AS uris),
    FROM join_options_as_columns),

get_labels_string AS (
  SELECT *,
  labels AS labels_string
  FROM parse_uris),

replace_outer_brackets AS (
  SELECT * 
  REPLACE ('{'||RTRIM(LTRIM(labels_string, '['), ']')||'}' AS  labels_string)
  FROM get_labels_string),

replace_structs AS (
  SELECT *
  EXCEPT (labels_string), 
  REPLACE(labels_string, 'STRUCT(', '') AS labels_string
  FROM replace_outer_brackets),

add_colons AS (
  SELECT *
  EXCEPT (labels_string), 
  REPLACE(labels_string, '",', '":') AS labels_string
  FROM replace_structs),

replace_trailing_brackets AS (
  SELECT *
  EXCEPT (labels_string), 
  REPLACE(labels_string, '")', '"') AS labels_string
  FROM add_colons),

convert_to_json AS (
  SELECT *, 
  TO_JSON(PARSE_JSON(labels_string)) AS labels_json
  FROM replace_trailing_brackets),

replace_labels_in_place AS (
  SELECT *
  EXCEPT (labels_string, labels_json)
  REPLACE (labels_json AS labels)
  FROM convert_to_json)


SELECT *
FROM replace_labels_in_place)