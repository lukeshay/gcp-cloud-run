locals {
  project_id = "lukeshay-cloud-run-examples"
  name       = "scala-ods"
}

resource "google_service_account" "subscription_google_service_account" {
  account_id = "${local.name}-subscription"
}

resource "google_cloud_run_service" "google_cloud_run_service" {
  name     = local.name
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.subscription_google_service_account.email
      containers {
        image = "us-central1-docker.pkg.dev/${local.project_id}/examples/${local.name}:${var.commit}"
      }
    }

    metadata {
      name        = "${local.name}-${var.commit}"
      annotations = {
        "autoscaling.knative.dev/maxScale"     = "100"
        "run.googleapis.com/client-name"       = "terraform"
        "run.googleapis.com/ingress-status"    = "internal"
        "run.googleapis.com/ingress"           = "internal"
        "serving.knative.dev/rollout-duration" = "300s"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "subscription_google_service_account" {
  service  = google_cloud_run_service.google_cloud_run_service.name
  location = google_cloud_run_service.google_cloud_run_service.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.subscription_google_service_account.email}"
}

resource "google_project_iam_member" "google_project_iam_member" {
  project = local.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.subscription_google_service_account.email}"
}

resource "google_pubsub_topic" "google_pubsub_topic" {
  name = local.name

  message_retention_duration = "86600s"
}

resource "google_pubsub_topic" "dead_letter_google_pubsub_topic" {
  name = "${local.name}-dead-letter"

  message_retention_duration = "86600s"
}

resource "google_pubsub_subscription" "google_pubsub_subscription" {
  name = local.name

  topic = google_pubsub_topic.google_pubsub_topic.name

  push_config {
    push_endpoint = google_cloud_run_service.google_cloud_run_service.status[0].url

    oidc_token {
      service_account_email = google_service_account.subscription_google_service_account.email
    }
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_google_pubsub_topic.id
    max_delivery_attempts = 10
  }
}

resource "google_storage_bucket" "google_storage_bucket" {
  name     = local.name
  location = "US"
}

resource "google_storage_bucket_iam_member" "google_storage_bucket_iam_member" {
  bucket = google_storage_bucket.google_storage_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.subscription_google_service_account.email}"
}