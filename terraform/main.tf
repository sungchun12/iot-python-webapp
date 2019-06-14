provider "google" {
  credentials = "service_account.json"
  project     = var.project
  region      = var.location
  zone        = var.zone
}

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

  #pass the root module variables ot child module
  project       = var.project
  location      = var.location
  zone          = var.zone
  version_label = var.version_label
}

