locals {
  project_name = "lukeshay-cloud-run-examples"
}

module "project_factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 13.0"

  billing_account   = "0174BC-58C206-6F7CFC"
  bucket_name       = local.project_name
  bucket_project    = local.project_name
  bucket_versioning = true
  name              = local.project_name
  org_id            = ""
  random_project_id = false

  activate_apis = [
    "artifactregistry.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudbilling.googleapis.com",
    "eventarc.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "storage-component.googleapis.com",
  ]
}


resource "google_artifact_registry_repository" "google_artifact_registry_repository" {
  provider = google-beta
  project  = module.project_factory.project_id

  location      = "us-central1"
  repository_id = "examples"
  description   = "GCP Cloud Run examples"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  provider = google-beta

  project    = google_artifact_registry_repository.google_artifact_registry_repository.project
  location   = google_artifact_registry_repository.google_artifact_registry_repository.location
  repository = google_artifact_registry_repository.google_artifact_registry_repository.name

  role = "roles/owner"
  members = [
    "user:shay.luke17@gmail.com",
  ]
}
