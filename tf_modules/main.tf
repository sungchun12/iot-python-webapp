# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SIMULATED IOT END TO END DATA PIPELINE
# This module creates the storage buckets, iot vms/registries, data ingestors, data warehouse, and real-time dashboard
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER DEFAULTS
# These variables are expected to be passed in by the operator
# You are expected to provide your own service account JSON file in the root module directory
# Note: The "google-beta" provider needs to be setup in ADDITION to the "google" provider
# ---------------------------------------------------------------------------------------------------------------------
provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.location
  zone        = var.zone
}

provider "google-beta" {
  credentials = var.credentials
  project     = var.project
  region      = var.location
  zone        = var.zone
}

# ---------------------------------------------------------------------------------------------------------------------
# ENABLE APIS
# These are expected to be passed in by the operator as a list
# Note: https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master/modules/project_services
# ---------------------------------------------------------------------------------------------------------------------

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services" #variables not allowed here
  version                     = "2.1.3"                                                                     #variables not allowed here
  project_id                  = var.project
  activate_apis               = var.api_services
  disable_services_on_destroy = var.disable_services_on_destroy_bool
  enable_apis                 = var.enable_apis_bool
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

  #pass the storage variables
  source_code_bucket_name = module.storage.source-code-bucket-metadata

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

module "secrets_manager" {
  source = "./modules/secrets_manager"

  #pass the root module variables to child module
  credentials   = var.credentials
  project       = var.project
  location      = var.location
  version_label = var.version_label
}

module "app_hosting" {
  source = "./modules/app_hosting"

  #pass the root module variables to child module
  project               = var.project
  location              = var.location
  zone                  = var.zone
  service_account_email = var.service_account_email
  version_label         = var.version_label

  #pass the secrets manager variables
  key_ring_id                               = module.secrets_manager.kms-keyring-metadata
  crypto_key_id                             = module.secrets_manager.kms-crypto-key-metadata
  google_application_credentials_ciphertext = module.secrets_manager.application-credentials-ciphertext

  #pass the iot module variables
  iot_registry_name = module.data_pipeline.iot-registry-metadata

  #pass the bigtable module variables
  bigtable_db_name    = module.data_pipeline.data-pipeline-bigtable-metadata
  bigtable_table_name = module.data_pipeline.data-pipeline-bigtable-table-metadata
  row_filter          = module.data_pipeline.data-pipeline-bigtable-rowfilter-metadata
}
