# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SIMULATED IOT END TO END DATA PIPELINE
# This module creates the storage buckets, iot vms/registries, data ingestors, data warehouse, and real-time dashboard
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER DEFAULTS
# These variables are expected to be passed in by the operator
# You are expected to provide your own service account JSON file in the root module directory
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  credentials = "service_account.json"
  project     = var.project
  region      = var.location
  zone        = var.zone
}

# ---------------------------------------------------------------------------------------------------------------------
# IMPORT MODULES
# This root module imports and passes through project wide variables
# Detailed variables contained within respective module directory
# ---------------------------------------------------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  # pass the root module variables to child module
  project       = var.project
  location      = var.location
  version_label = var.version_label
}

module "data_pipeline" {
  source = "./modules/data_pipeline"

  # pass the root module variables to child  module
  project               = var.project
  location              = var.location
  zone                  = var.zone
  service_account_email = var.service_account_email
  version_label         = var.version_label
}

module "iot_compute" {
  source = "./modules/iot_compute"

  #pass the root module variables to child module
  project               = var.project
  location              = var.location
  zone                  = var.zone
  service_account_email = var.service_account_email
  version_label         = var.version_label
}

