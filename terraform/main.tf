resource "google_bigquery_dataset" "create_datasets" {
  project                    = var.project_id
  for_each                   = toset(var.regions)
  dataset_id                 = replace(each.value, "-", "_")
  location                   = each.value
  delete_contents_on_destroy = true
}
