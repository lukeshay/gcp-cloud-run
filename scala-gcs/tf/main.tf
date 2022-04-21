locals {
  project_id = "lukeshay-cloud-run-examples"
  name       = "scala-data-capture"
}

resource "google_service_account" "invoker_google_service_account" {
  provider = google-beta

  account_id = "${local.name}-invoker"
}

resource "google_service_account" "receiver_google_service_account" {
  provider = google-beta

  account_id = "${local.name}-receiver"
}

resource "google_project_iam_binding" "receiver_google_project_iam_binding" {
  provider = google-beta
  project  = local.project_id

  role = "roles/eventarc.eventReceiver"

  members = [
    "serviceAccount:${google_service_account.receiver_google_service_account.email}"
  ]
}

resource "google_cloud_run_service" "google_cloud_run_service" {
  provider = google-beta

  name     = local.name
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.receiver_google_service_account.email
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
  provider = google-beta

  service  = google_cloud_run_service.google_cloud_run_service.name
  location = google_cloud_run_service.google_cloud_run_service.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.invoker_google_service_account.email}"
}

resource "google_pubsub_topic" "google_pubsub_topic" {
  provider = google-beta

  name = local.name

  message_retention_duration = "86600s"
}

resource "google_eventarc_trigger" "google_eventarc_trigger" {
  provider = google-beta

  name     = local.name
  location = google_cloud_run_service.google_cloud_run_service.location
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.google_cloud_run_service.name
      region  = google_cloud_run_service.google_cloud_run_service.location
    }
  }
  transport {
    pubsub {
      topic = google_pubsub_topic.google_pubsub_topic.name
    }
  }

  service_account = google_service_account.invoker_google_service_account.email
}
