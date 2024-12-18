terraform {
  required_version = ">= 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.14.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "eu"
  alias   = "eu"
}
