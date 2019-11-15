# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE THE ClOUD BUILD TRIGGER
# This module creates a cloud build resorce triggered by any changes in the named branch
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "google_cloudbuild_trigger" "cloudbuild-trigger" {
  provider = "google-beta"

  # 3.0.0 google provider has breaking changes with a required trigger_template
  trigger_template {
    branch_name = var.github_branch_name
   # repo_name = var.repo_name
  }

  github {
    owner = var.github_owner
    name  = var.repo_name
    push {
      branch = var.github_branch_name
    }
  }

  filename = var.filename
}
