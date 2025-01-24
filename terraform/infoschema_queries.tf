resource "google_bigquery_routine" "columns_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "columns_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.columns query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/column_field_paths_query.sql")
}

resource "google_bigquery_routine" "column_field_paths_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "column_field_paths_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.column_field_paths query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/columns_query.sql")
}

resource "google_bigquery_routine" "datasets_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "datasets_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.datasets query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "region"
    data_type = jsonencode({ typeKind = "STRING" })
  }
  definition_body = file("infoschema_queries/datasets_query.sql")
}

resource "google_bigquery_routine" "partitions_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "partitions_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.partitions query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/partitions_query.sql")
}

resource "google_bigquery_routine" "table_metadata_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_metadata_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.table_metadata query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/table_metadata_query.sql")
}

resource "google_bigquery_routine" "table_options_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_options_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.table_options query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/table_options_query.sql")
}

resource "google_bigquery_routine" "tables_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "tables_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "infoschema.tables query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "dataset_ids"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("infoschema_queries/tables_query.sql")
}