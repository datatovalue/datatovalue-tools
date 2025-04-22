((
SELECT ARRAY_TO_STRING (
  [
    "CREATE OR REPLACE TABLE FUNCTION",
    "`"||deployed_parser_id||"`(start_date DATE, end_date DATE)",
    "AS ((",
    "WITH",
    "input_data AS (",
    "SELECT",
    json_column_name||" AS input_json",
    "FROM `"||source_table_id||"`",
    "WHERE DATE(_PARTITIONTIME) BETWEEN start_date AND end_date",
    "),",
    " ",
    "parse_json AS (",
    `datatovalue-tools.${region_dataset}.build_json_parser_body`(json_schema),
    "FROM input_data",
    ")",
    " ",
    "SELECT AS STRUCT *",
    "FROM parse_json",
    "))"
  ], "\n")
))