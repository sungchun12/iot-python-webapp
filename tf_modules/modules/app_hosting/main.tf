# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE CLOUD RUN SERVICE TO DEPLOY REAL-TIME PYTHON APP
# This module creates a cloud run resource and references 
# the main python application code in an upstream directory
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

# need to push an image outside of terraform for the container repo and image to populate
data "google_container_registry_image" "dash-cloudrun-demo" {
  name    = var.container_image_name
  project = var.project
}

data "google_compute_default_service_account" "default" {}

resource "google_project_iam_binding" "service-account-decrypter" {
  project = var.project
  role    = "roles/cloudkms.cryptoKeyDecrypter"

  members = [
    join(":", ["serviceAccount", data.google_compute_default_service_account.default.email])
  ]
}

resource "google_cloud_run_service" "tf-dash-cloud-run-demo" {
  provider = "google-beta"
  name     = var.cloud_run_name
  location = var.location
  # policy_data = data.google_iam_policy.cloud-run-access.policy_data

  metadata {
    namespace = var.project
    labels = {
      version = var.version_label
    }
  }

  spec {
    containers {
      image = data.google_container_registry_image.dash-cloudrun-demo.image_url
      env {
        name  = "GCLOUD_PROJECT_NAME"
        value = var.project
      }
      env {
        name  = "BIGTABLE_CLUSTER"
        value = var.bigtable_db_name
      }
      env {
        name  = "TABLE_NAME"
        value = var.bigtable_table_name
      }
      env {
        name  = "CLOUD_REGION"
        value = var.location
      }
      env {
        name  = "IOT_REGISTRY"
        value = var.iot_registry_name
      }
      env {
        name  = "ROW_FILTER"
        value = var.row_filter
      }
      env {
        name  = "KEY_RING_ID"
        value = var.key_ring_id
      }
      env {
        name  = "CRYPTO_KEY_ID"
        value = var.crypto_key_id
      }
      env {
        name  = "GOOGLE_APP_CREDENTIALS"
        value = var.google_application_credentials_ciphertext
      }
    }
  }
}

#add iam policy binding for anyone to access the url
data "google_iam_policy" "cloud-run-access" {
  binding {
    role = "roles/run.invoker"

    members = [
      "allUsers",
    ]
  }
}


# The Service is ready to be used when the "Ready" condition is True
# Due to Terraform and API limitations this is best accessed through a local variable
locals {
  cloud_run_status = {
    for cond in google_cloud_run_service.tf-dash-cloud-run-demo.status[0].conditions :
    cond.type => cond.status
  }
}

output "isReady" {
  value = local.cloud_run_status["Ready"] == "True"
}
