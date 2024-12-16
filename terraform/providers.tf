terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

# -----------------------------------
# Multi-Region Providers
# -----------------------------------

# US Multi-Region
provider "google" {
  project = var.project_id
  region  = "us"
  alias   = "us"
}

# Europe Multi-Region
provider "google" {
  project = var.project_id
  region  = "eu"
  alias   = "eu"
}

# -----------------------------------
# North America Providers
# -----------------------------------

provider "google" {
  project = var.project_id
  region  = "us-central1"
  alias   = "us-central1"
}

provider "google" {
  project = var.project_id
  region  = "us-east1"
  alias   = "us-east1"
}

provider "google" {
  project = var.project_id
  region  = "us-east4"
  alias   = "us-east4"
}

provider "google" {
  project = var.project_id
  region  = "us-west1"
  alias   = "us-west1"
}

provider "google" {
  project = var.project_id
  region  = "us-west2"
  alias   = "us-west2"
}

provider "google" {
  project = var.project_id
  region  = "us-west3"
  alias   = "us-west3"
}

provider "google" {
  project = var.project_id
  region  = "us-west4"
  alias   = "us-west4"
}

provider "google" {
  project = var.project_id
  region  = "northamerica-northeast1"
  alias   = "northamerica-northeast1"
}

# -----------------------------------
# Europe Providers
# -----------------------------------

provider "google" {
  project = var.project_id
  region  = "europe-west1"
  alias   = "europe-west1"
}

provider "google" {
  project = var.project_id
  region  = "europe-west2"
  alias   = "europe-west2"
}

provider "google" {
  project = var.project_id
  region  = "europe-west3"
  alias   = "europe-west3"
}

provider "google" {
  project = var.project_id
  region  = "europe-west4"
  alias   = "europe-west4"
}

provider "google" {
  project = var.project_id
  region  = "europe-north1"
  alias   = "europe-north1"
}

provider "google" {
  project = var.project_id
  region  = "europe-southwest1"
  alias   = "europe-southwest1"
}

provider "google" {
  project = var.project_id
  region  = "me-central1"
  alias   = "me-central1"
}

provider "google" {
  project = var.project_id
  region  = "me-west1"
  alias   = "me-west1"
}

provider "google" {
  project = var.project_id
  region  = "europe-west6"
  alias   = "europe-west6"
}

# -----------------------------------
# Asia-Pacific Providers
# -----------------------------------

provider "google" {
  project = var.project_id
  region  = "asia-east1"
  alias   = "asia-east1"
}

provider "google" {
  project = var.project_id
  region  = "asia-east2"
  alias   = "asia-east2"
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
  alias   = "asia-northeast1"
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast2"
  alias   = "asia-northeast2"
}

provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
  alias   = "asia-northeast3"
}

provider "google" {
  project = var.project_id
  region  = "asia-south1"
  alias   = "asia-south1"
}

provider "google" {
  project = var.project_id
  region  = "asia-south2"
  alias   = "asia-south2"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast1"
  alias   = "asia-southeast1"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast2"
  alias   = "asia-southeast2"
}

provider "google" {
  project = var.project_id
  region  = "asia-southeast3"
  alias   = "asia-southeast3"
}

provider "google" {
  project = var.project_id
  region  = "australia-southeast1"
  alias   = "australia-southeast1"
}

provider "google" {
  project = var.project_id
  region  = "australia-southeast2"
  alias   = "australia-southeast2"
}

# -----------------------------------
# South America Providers
# -----------------------------------

provider "google" {
  project = var.project_id
  region  = "southamerica-east1"
  alias   = "southamerica-east1"
}
