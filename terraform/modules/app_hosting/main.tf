# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE CLOUD RUN SERVICE TO DEPLOY REAL-TIME PYTHON APP
# This module creates a cloud run resource and references 
# the main python application code in an upstream directory
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloud_run_service" "default" {
  name     = "tftest-cloudrun"
  location = var.location
  provider = "google-beta"

  metadata {
    namespace = var.project
  }

  spec {
    containers {
      image = "gcr.io/cloudrun/hello"
    }
  }
}

# The Service is ready to be used when the "Ready" condition is True
# Due to Terraform and API limitations this is best accessed through a local variable
locals {
  cloud_run_status = {
    for cond in google_cloud_run_service.default.status[0].conditions :
    cond.type => cond.status
  }
}

output "isReady" {
  value = local.cloud_run_status["Ready"] == "True"
}
