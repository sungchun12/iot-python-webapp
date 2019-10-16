# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY RAW DATA, STAGING, AND SOURCE CODE BUCKETS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "google_kms_key_ring" "cloud-run-keyring" {
  project  = var.project
  name     = var.key_ring_name
  location = var.location
}

resource "google_kms_crypto_key" "iot-python-webapp-key" {
  name     = var.webapp_key_name
  key_ring = google_kms_key_ring.cloud-run-keyring.self_link
}

data "google_kms_secret_ciphertext" "application-credentials" {
  crypto_key = google_kms_crypto_key.iot-python-webapp-key.self_link
  plaintext  = var.credentials
}
