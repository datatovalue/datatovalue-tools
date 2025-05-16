resource "google_bigquery_routine" "deploy_monitor_tables_view_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "deploy_monitor_tables_view_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "deploy_monitor_tables_view query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "config"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = templatefile("monitor/deploy_monitor_tables_tvf_query.sql", { region = replace(each.value, "-", "_"), release_version = var.release_version })
}