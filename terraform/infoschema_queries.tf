resource "google_bigquery_routine" "tables_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "tables_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "tables query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/tables_query.sql")
}