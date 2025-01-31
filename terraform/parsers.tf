resource "google_bigquery_routine" "parse_dependencies" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "parse_dependencies"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "parse_dependencies table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dependencies_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("parsers/parse_dependencies.sql")
}