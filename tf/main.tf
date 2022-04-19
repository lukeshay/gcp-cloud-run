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

resource "google_cloud_run_service" "google_cloud_run_service" {
  name     = "rust-pub-sub"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/rust-examples/examples/pub-sub:e3e3c10"
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"     = "100"
        "run.googleapis.com/client-name"       = "terraform"
        "run.googleapis.com/ingress-status"    = "all"
        "run.googleapis.com/ingress"           = "all"
        "serving.knative.dev/rollout-duration" = "300s"
      }
    }
  }
  autogenerate_revision_name = true

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth_google_iam_policy" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "google_cloud_run_service_iam_policy" {
  location = google_cloud_run_service.google_cloud_run_service.location
  project  = google_cloud_run_service.google_cloud_run_service.project
  service  = google_cloud_run_service.google_cloud_run_service.name

  policy_data = data.google_iam_policy.noauth_google_iam_policy.policy_data
}
