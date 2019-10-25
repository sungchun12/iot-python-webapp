# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE ClOUD BUILD TRIGGER
# This module creates a cloud build resorce triggered by any changes in the named branch
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "cloudbuild-trigger" {
  trigger_template {
    branch_name = var.branch_name
    repo_name   = var.repo_name
  }

  filename = var.filename
}
