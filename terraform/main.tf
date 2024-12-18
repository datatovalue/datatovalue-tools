resource "google_bigquery_dataset" "create_datasets" {
  project                    = var.project_id
  for_each                   = toset(var.regions)
  dataset_id                 = replace(each.value, "-", "_")
  location                   = each.value
  description                = "datatovalue-tools v${var.release_version}"
  delete_contents_on_destroy = true
  labels = {
    datatovalue-tools-version = "v${replace(var.release_version,".", "_")}"
  }
}
