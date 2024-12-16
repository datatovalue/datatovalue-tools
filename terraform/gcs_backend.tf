resource "random_id" "default" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name                        = "datatovalue-tools-${random_id.default.hex}"
  location                    = "EU"
  project                     = var.project_id
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "local_file" "default" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"
  content         = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.default.name}"
    }
  }
  EOT
}