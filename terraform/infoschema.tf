resource "google_bigquery_routine" "tables" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "tables"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.tables table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "tables_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/tables.sql")
}