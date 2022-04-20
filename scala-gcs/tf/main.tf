locals {
  project_id = "lukeshay-cloud-run-examples"
  name       = "scala-gcs"
}

resource "google_service_account" "google_service_account" {
  account_id = local.name
}

resource "google_cloud_run_service" "google_cloud_run_service" {
  name     = local.name
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.google_service_account.email
      containers {
        image = "us-central1-docker.pkg.dev/${local.project_id}/examples/${local.name}:${var.commit}"
      }
    }

    metadata {
      name = "${local.name}-${var.commit}"
      annotations = {
        "autoscaling.knative.dev/maxScale"     = "100"
        "run.googleapis.com/client-name"       = "terraform"
        "run.googleapis.com/ingress-status"    = "all"
        "run.googleapis.com/ingress"           = "all"
        "serving.knative.dev/rollout-duration" = "300s"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "noauth" {
  service  = google_cloud_run_service.google_cloud_run_service.name
  location = google_cloud_run_service.google_cloud_run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
