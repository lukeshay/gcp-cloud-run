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
  repository_id = "pub-sub"
  description   = "Rust examples"
  format        = "DOCKER"
}

resource "google_cloud_run_service" "google_cloud_run_service" {
  name     = "rust-pub-sub"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"  = "100"
        "run.googleapis.com/client-name"    = "terraform"
        "run.googleapis.com/ingress"        = "internal"
        "run.googleapis.com/ingress-status" = "internal"
      }
    }
  }
  autogenerate_revision_name = true

  traffic {
    percent         = 100
    latest_revision = true
  }
}
