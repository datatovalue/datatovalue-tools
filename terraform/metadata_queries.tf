resource "google_bigquery_routine" "table_shape_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_shape_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "table_shape query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "columns_json"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = replace(file("metadata_queries/table_shape_query.sql"), "${var.template_project_id}.${var.template_dataset_id}", format("%s.%s", var.project_id, replace(each.value, "-", "_")))
}
