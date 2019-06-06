provider "google" {
  credentials = "service_account.json"
  project     = var.project
  region      = var.location
  zone        = var.zone
}

module "storage" {
  source = "./modules/storage"
  # version = "0.0.1"

  # pass the root module variables to child module
  project             = var.project
  location            = var.location
  version_label       = var.version_label
  raw_bucket_name     = var.raw_bucket_name
  staging_bucket_name = var.staging_bucket_name
  storage_class       = var.storage_class
  versioning_enabled  = var.versioning_enabled
  main_page_suffix    = var.main_page_suffix
  not_found_page      = var.not_found_page
}

module "data_pipeline" {
  source = "./modules/data_pipeline"
  # version = "0.0.1"

  # pass the root module variables to child  module
  project  = var.project
  location = var.location
  zone     = var.zone
}

module "iot_compute" {
  source = "./modules/iot_compute"
  # version = "0.0.1"

  #pass the root module variables ot child module
  project  = var.project
  location = var.location
  zone     = var.zone
}

