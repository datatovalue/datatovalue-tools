resource "google_bigquery_routine" "row_duplicate_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "row_duplicate_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "row_duplicate_query generator"
  language     = "SQL"
  arguments {
    name      = "table_id"
    data_type = jsonencode({ "typeKind": "STRING"})
  }
  definition_body = file("functions/row_duplicate_query.txt")
}

resource "google_bigquery_routine" "unique_combination_query" {
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "unique_combination_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "unique_combination_query generator"
  language     = "SQL"
  arguments {
    name      = "table_id"
    data_type = jsonencode({ "typeKind": "STRING"})
    }
  arguments {
    name = "input_strings"
    data_type = {type_kind = "ARRAY", array_type = "STRING"}
    }
  definition_body = file("functions/unique_combination_query.txt")
}


