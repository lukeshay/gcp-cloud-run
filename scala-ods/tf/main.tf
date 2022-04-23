locals {
  project_id = "lukeshay-cloud-run-examples"
  name       = "scala-ods"
}

resource "google_service_account" "invoker_google_service_account" {
  provider = google-beta

  account_id = "${local.name}-invoker"
}

resource "google_service_account" "receiver_google_service_account" {
  provider = google-beta

  account_id = "${local.name}-receiver"
}

resource "google_service_account" "dead_letter_google_service_account" {
  provider = google-beta

  account_id = "${local.name}-dead-letter"
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
      name        = "${local.name}-${var.commit}"
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

resource "google_cloud_run_service_iam_member" "invoker_google_cloud_run_service_iam_member" {
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

resource "google_pubsub_topic" "dead_letter_google_pubsub_topic" {
  provider = google-beta

  name = "${local.name}-dead-letter"

  message_retention_duration = "86600s"
}

resource "google_pubsub_topic_iam_member" "member" {
  project = google_pubsub_topic.dead_letter_google_pubsub_topic.project
  topic   = google_pubsub_topic.dead_letter_google_pubsub_topic.name
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.dead_letter_google_service_account.email}"
}

resource "google_storage_bucket" "google_storage_bucket" {
  name     = "${local.name}-dead-letter"
  location = "US"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.google_storage_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.dead_letter_google_service_account.email}"
}

resource "google_dataflow_job" "google_dataflow_job" {
  name                    = "${local.name}-dead-letter"
  template_gcs_path       = "gs://dataflow-templates-us-central1/latest/Cloud_PubSub_to_GCS_Text"
  temp_gcs_location       = "gs://${google_storage_bucket.google_storage_bucket.name}/temp"
  enable_streaming_engine = true
  parameters              = {
    inputTopic           = google_pubsub_topic.dead_letter_google_pubsub_topic.id
    outputDirectory      = "gs://${google_storage_bucket.google_storage_bucket.name}/output"
    outputFilenamePrefix = "output"
  }
  service_account_email = google_service_account.dead_letter_google_service_account.email
  on_delete             = "cancel"
}

resource "google_pubsub_subscription" "google_pubsub_subscription" {
  provider = google-beta

  name = local.name

  topic = google_pubsub_topic.google_pubsub_topic.name

  push_config {
    push_endpoint = google_cloud_run_service.google_cloud_run_service.status[0].url

    oidc_token {
      service_account_email = google_service_account.invoker_google_service_account.email
    }
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_google_pubsub_topic.id
    max_delivery_attempts = 10
  }
}
