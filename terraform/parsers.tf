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

resource "google_bigquery_routine" "parse_sql_ctes" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "parse_sql_ctes"
  routine_type = "SCALAR_FUNCTION"
  description  = "parse_sql_ctes function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "sql_query"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  definition_body = file("parsers/parse_sql_ctes.sql")
}