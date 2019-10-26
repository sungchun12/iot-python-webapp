# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE ClOUD BUILD TRIGGER
# This module creates a cloud build resorce triggered by any changes in the named branch
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUD RUN SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudbuild_trigger" "cloudbuild-trigger" {
  provider = "google-beta"

  github {
    owner = var.owner
    name  = var.repo_name
    push {
      branch = var.branch_name
    }
  }

  filename = var.filename
}
