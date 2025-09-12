provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "crypto_key" {
  name            = var.crypto_key_name
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "100000s" # Optional: Key rotation

  lifecycle {
    prevent_destroy = true
  }
}


variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for the KMS resources (e.g., us-central1)"
  type        = string
}

variable "key_ring_name" {
  description = "Name of the KMS Key Ring"
  type        = string
}

variable "crypto_key_name" {
  description = "Name of the KMS Crypto Key"
  type        = string
}


project_id      = "your-gcp-project-id"
region          = "us-central1"
key_ring_name   = "example-key-ring"
crypto_key_name = "example-crypto-key"
