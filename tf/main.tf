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

locals {
  commit = "fb07a78"
}

# Used to retrieve project_number later
data "google_project" "project" {
  provider = google-beta
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  provider           = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Eventarc API
resource "google_project_service" "eventarc" {
  provider           = google-beta
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "google_service_account" {
  account_id = "rust-pub-sub"
}

resource "google_cloud_run_service" "google_cloud_run_service" {
  provider = google-beta

  name     = "rust-pub-sub"
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.google_service_account.email
      containers {
        image = "us-central1-docker.pkg.dev/rust-examples/examples/pub-sub:${local.commit}"
      }
    }

    metadata {
      name = "rust-pub-sub-${local.commit}"
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

  depends_on = [google_project_service.run]
}

resource "google_cloud_run_service_iam_member" "noauth" {
  provider = google-beta

  service  = google_cloud_run_service.google_cloud_run_service.name
  location = google_cloud_run_service.google_cloud_run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_pubsub_topic" "google_pubsub_topic" {
  name = "rust-pub-sub"

  message_retention_duration = "86600s"
}

resource "google_eventarc_trigger" "google_eventarc_trigger" {
  provider = google-beta
  name     = "rust-pub-sub"
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

  depends_on = [google_project_service.eventarc]
}

# Give default Compute service account eventarc.eventReceiver role
resource "google_project_iam_binding" "project" {
  provider = google-beta
  project  = data.google_project.project.id
  role     = "roles/eventarc.eventReceiver"

  members = [
    "serviceAccount:${google_service_account.google_service_account.email}"
  ]
}

# Create an AuditLog for Cloud Storage trigger
resource "google_eventarc_trigger" "auditlog_google_eventarc_trigger" {
  provider = google-beta

  name     = "rust-pub-sub-auditlog"
  location = google_cloud_run_service.google_cloud_run_service.location
  project  = data.google_project.project.id
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.audit.log.v1.written"
  }
  matching_criteria {
    attribute = "serviceName"
    value     = "storage.googleapis.com"
  }
  matching_criteria {
    attribute = "methodName"
    value     = "storage.objects.create"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.google_cloud_run_service.name
      region  = google_cloud_run_service.google_cloud_run_service.location
    }
  }
  service_account = google_service_account.google_service_account.email

  depends_on = [google_project_service.eventarc]
}

# resource "google_pubsub_subscription" "google_pubsub_subscription" {
#   name  = "rust-pub-sub"
#   topic = google_pubsub_topic.google_pubsub_topic.name

#   ack_deadline_seconds = 20

#   push_config {
#     push_endpoint = google_cloud_run_service.google_cloud_run_service.status[0].url
#   }
# }
