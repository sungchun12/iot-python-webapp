# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE CLOUD RUN SERVICE TO DEPLOY REAL-TIME PYTHON APP
# This module creates a cloud run resource and references 
# the main python application code in an upstream directory
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

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
      image = var.container_image
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