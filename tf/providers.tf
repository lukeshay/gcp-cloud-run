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
  region = "us-central1"
}

provider "google-beta" {
  region = "us-central1"
}

