resource "google_bigquery_routine" "column_field_paths" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "column_field_paths"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.column_field_paths table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "column_field_paths_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/column_field_paths.sql")
}

resource "google_bigquery_routine" "columns" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "columns"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.columns table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "columns_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/columns.sql")
}

resource "google_bigquery_routine" "datasets" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "datasets"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.datasets table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "datasets_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/datasets.sql")
}

resource "google_bigquery_routine" "partitions" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "partitions"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.partitions table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "partitions_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/partitions.sql")
}

resource "google_bigquery_routine" "table_metadata" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_metadata"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.table_metadata table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_metadata_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/table_metadata.sql")
}

resource "google_bigquery_routine" "table_options" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_options"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.table_options table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_options_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/table_options.sql")
}

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

resource "google_bigquery_routine" "table_storage" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_storage"
  routine_type = "TABLE_VALUED_FUNCTION"
  description  = "infoschema.table_storage table function v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_storage_json"
    data_type = jsonencode({ "typeKind" : "JSON" })
  }
  definition_body = file("infoschema/table_storage.sql")
}