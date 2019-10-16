output "kms-keyring-metadata" {
  value = google_kms_key_ring.cloud-run-keyring.name
}

output "kms-crypto-key-metadata" {
  value = google_kms_crypto_key.iot-python-webapp-key.name
}

