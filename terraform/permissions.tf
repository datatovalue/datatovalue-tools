resource "google_bigquery_dataset_iam_binding" "set_permissions_for_all_regions" {
  project    = var.project_id
  for_each   = toset(var.regions)
  dataset_id = replace(each.value, "-", "_")
  role       = "roles/bigquery.dataViewer"
  members    = ["allAuthenticatedUsers"]
}