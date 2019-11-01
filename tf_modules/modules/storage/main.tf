# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY RAW DATA, DATAFLOW STAGING, AND SOURCE CODE BUCKETS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
resource "google_storage_bucket" "data-store" {

  name          = join("-", [var.project, var.raw_bucket_name])
  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  force_destroy = true

  versioning {
    enabled = var.versioning_enabled
  }

  website {
    main_page_suffix = var.main_page_suffix
    not_found_page   = var.not_found_page
  }

  labels = {
    version = var.version_label
  }
}

resource "google_storage_bucket" "dataflow-staging" {

  name = join("-", [var.project, var.staging_bucket_name])

  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  force_destroy = true

  versioning {
    enabled = var.versioning_enabled
  }

  website {
    main_page_suffix = var.main_page_suffix
    not_found_page   = var.not_found_page
  }

  labels = {
    version = var.version_label
  }
}

resource "google_storage_bucket" "source-code-bucket" {
  name = join("-", [var.project, var.source_code_bucket_name])

  location      = var.location
  project       = var.project
  storage_class = var.storage_class
  force_destroy = true

  versioning {
    enabled = var.versioning_enabled
  }

  website {
    main_page_suffix = var.main_page_suffix
    not_found_page   = var.not_found_page
  }

  labels = {
    version = var.version_label
  }
}
