resource "google_bigquery_routine" "table_shape" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_shape"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "metadata.table_shape table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_shape_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("metadata/table_shape.sql")
}