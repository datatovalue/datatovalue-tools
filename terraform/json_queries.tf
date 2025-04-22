resource "google_bigquery_routine" "deploy_json_parser_udf_query" {
  depends_on   = [google_bigquery_routine.build_json_parser_body]
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "deploy_json_parser_udf_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "deploy_json_parser_udf_query v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "json_schema"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "deployed_parser_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  definition_body = templatefile("./json_query/deploy_json_parser_udf_query.sql", { region_dataset = replace(each.value, "-", "_") })
}


resource "google_bigquery_routine" "deploy_json_parser_tvf_query" {
  depends_on   = [google_bigquery_routine.build_json_parser_body]
  project      = var.project_id
  for_each     = toset(var.regions)
  dataset_id   = replace(each.value, "-", "_")
  routine_id   = "deploy_json_parser_tvf_query"
  routine_type = "SCALAR_FUNCTION"
  description  = "deploy_json_parser_tvf_query v${var.release_version}"
  language     = "SQL"
  arguments {
    name      = "json_schema"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "deployed_parser_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "source_table_id"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  arguments {
    name      = "json_column_name"
    data_type = jsonencode({ "typeKind" : "STRING" })
  }
  definition_body = templatefile("./json_query/deploy_json_parser_tvf_query.sql", { region_dataset = replace(each.value, "-", "_"), })
}