resource "google_bigquery_routine" "table_shape" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_shape"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "table_shape table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_shape_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("metadata/table_shape.sql")
}

resource "google_bigquery_routine" "deploy_table_shard_metadata" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "deploy_table_shard_metadata"
  routine_type = "SCALAR_FUNCTION"
  description  = "deploy_table_shard_metadata query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "options"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = templatefile("deploy_metadata_queries/deploy_table_shard_metadata_tvf_query.sql", { region = replace(each.value, "-", "_"), release_version = var.release_version })
}

resource "google_bigquery_routine" "deploy_storage_billing_model" {
  depends_on = [ google_bigquery_routine.storage_billing_model_query ]
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "deploy_storage_billing_model"
  routine_type = "SCALAR_FUNCTION"
  description  = "deploy_storage_billing_model query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "options"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = templatefile("deploy_metadata_queries/deploy_storage_billing_model_tvf_query.sql", { region = replace(each.value, "-", "_"), release_version = var.release_version })
}