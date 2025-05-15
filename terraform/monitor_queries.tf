resource "google_bigquery_routine" "monitor_tables_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "monitor_tables_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "monitor_tables_query query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "config"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = file("monitor_queries/monitor_tables_query.sql")
}
