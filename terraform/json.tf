resource "google_bigquery_routine" "build_json_parser_body" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "build_json_parser_body"
  routine_type = "SCALAR_FUNCTION"
  description  = "build_json_parser_body v${var.release_version}"
  language     = "JAVASCRIPT"
  arguments {
    name      = "input_schema"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  return_type = jsonencode({ "typeKind" : "STRING" })
  definition_body = file("json/build_json_parser_body.sql")
}

