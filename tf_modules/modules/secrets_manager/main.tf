# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY KEY MANAGEMENT SERVICES KEY RING, KEY, AND ENCRYPTED CREDENTIALS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
provider "random" {
  version          = "~> 2.2.1"
}

resource "random_string" "random" {
  length           = 10
  special          = false
}

resource "google_kms_key_ring" "cloud-run-keyring" {
  project = var.project
  # this prevent error when creating a new key as the old name cannot be overwritten within the project for recordkeeping
  name     = join("-", [var.key_ring_name, random_string.random.result])
  location = var.location
}

resource "google_kms_crypto_key" "iot-python-webapp-key" {
  name     = var.webapp_key_name
  key_ring = google_kms_key_ring.cloud-run-keyring.self_link
}

data "google_kms_secret_ciphertext" "application-credentials" {
  crypto_key = google_kms_crypto_key.iot-python-webapp-key.self_link
  plaintext  = var.secrets
}
