resource "google_storage_bucket" "data-store" {
  name = var.raw_bucket_name

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
  name = var.staging_bucket_name

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

