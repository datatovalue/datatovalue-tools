
resource "google_bigquery_routine" "row_duplicate_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "row_duplicate_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "row_duplicate_query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  definition_body = file("functions/row_duplicate_query.sql")
}

resource "google_bigquery_routine" "unique_combination_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "unique_combination_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "unique_combination_query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "column_names"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("functions/unique_combination_query.sql")
}

resource "google_bigquery_routine" "table_date_partitions_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "table_date_partitions_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "table_date_partitions_query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "project_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "dataset_names"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } })
  }
  definition_body = file("functions/table_date_partitions_query.sql")
}