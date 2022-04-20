terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.18"
    }
  }
  backend "gcs" {
    bucket = "lukeshay-cloud-run-examples"
    prefix = "terraform-state/scala-gcs"
  }
}

provider "google" {
  project = local.project_id
  region  = "us-central1"
}
