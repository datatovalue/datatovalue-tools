((
SELECT ARRAY_TO_STRING (
  [
    "CREATE OR REPLACE FUNCTION",
    "`"||deployed_parser_id||"`(input_json STRING)",
    "AS ((",
    `datatovalue-tools.${region_dataset}.build_json_parser_body`(json_schema),
    "))"
  ], "\n")
))