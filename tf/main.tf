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
}

provider "google" {
  project = "rust-examples"
  region  = "us-central1"
}

provider "google-beta" {
  project = "rust-examples"
  region  = "us-central1"
}

resource "google_artifact_registry_repository" "google_artifact_registry_repository" {
  provider = google-beta

  location      = "us-central1"
  repository_id = "examples"
  description   = "Rust examples"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  provider   = google-beta
  
  project    = google_artifact_registry_repository.google_artifact_registry_repository.project
  location   = google_artifact_registry_repository.google_artifact_registry_repository.location
  repository = google_artifact_registry_repository.google_artifact_registry_repository.name
  
  role       = "roles/owner"
  members = [
    "user:shay.luke17@gmail.com",
  ]
}
