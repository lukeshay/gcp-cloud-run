terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.18"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.18"
    }
  }
  backend "gcs" {
    bucket = "lukeshay-cloud-run-examples"
    prefix = "terraform-state/rust-pub-sub"
  }
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}

provider "google-beta" {
  project = local.project_id
  region  = "us-central1"
}
