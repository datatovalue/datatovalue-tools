
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

resource "google_bigquery_routine" "column_profile_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "column_profile_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "column_profile_query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  definition_body = file("functions/column_profile_query.sql")
}

resource "google_bigquery_routine" "unique_combination_multi_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "unique_combination_multi_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "unique_combination_multi_query generator v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "table_column_combinations"
    data_type = jsonencode({ typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRUCT", "structType" : { "fields" : [{ "name" : "table_id", "type" : { "typeKind" : "STRING" } }, { "name" : "column_names", "type" : { typeKind = "ARRAY", "arrayElementType" : { "typeKind" : "STRING" } } }] } } })
  }
  definition_body = replace(file("functions/unique_combination_multi_query.sql"), "${var.template_project_id}.${var.template_dataset_id}", "${var.project_id}.${replace(each.value, "-", "_")}")
}
