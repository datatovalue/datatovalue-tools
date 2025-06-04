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

resource "google_bigquery_routine" "table_shard_metadata_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_shard_metadata_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "table_shard_metadata query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "options"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = file("metadata_queries/table_shard_metadata_query.sql")
}

resource "google_bigquery_routine" "storage_billing_model_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "storage_billing_model_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "storage_billing_model query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "options"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = templatefile("./metadata_queries/storage_billing_model_query.sql", { region = each.value })
}


resource "google_bigquery_routine" "set_dataset_options_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "set_dataset_options_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "set_dataset_options query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "options"
    data_type = jsonencode({ typeKind = "JSON" })
  }
  definition_body = templatefile("./metadata_queries/set_dataset_options_query.sql", { region = each.value })
}




