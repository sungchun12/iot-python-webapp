provider "google" {
  credentials = "service_account.json"
  project     = var.project
  region      = var.location
  zone        = var.zone
}

module "storage" {
  source = "./modules/storage"

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

  # pass the root module variables to child  module
  project                   = var.project
  location                  = var.location
  zone                      = var.zone
  service_account_email     = var.service_account_email
  version_label             = var.version_label
  iot_registry_name         = var.iot_registry_name
  http_config_state         = var.http_config_state
  mqtt_config_state         = var.mqtt_config_state
  data_pipeline_topic_name  = var.data_pipeline_topic_name
  device_status_topic_name  = var.device_status_topic_name
  dataset_name              = var.dataset_name
  dataset_desc              = var.dataset_desc
  table_name                = var.table_name
  table_desc                = var.table_desc
  bigtable_db_name          = var.bigtable_db_name
  bigtable_db_instance_type = var.bigtable_db_instance_type
  bigtable_db_cluster_name  = var.bigtable_db_cluster_name
  bigtable_db_storage_type  = var.bigtable_db_storage_type
  bigtable_table_name       = var.bigtable_table_name
  bigtable_table_split_keys = var.bigtable_table_split_keys
}

module "iot_compute" {
  source = "./modules/iot_compute"

  #pass the root module variables ot child module
  project                  = var.project
  location                 = var.location
  zone                     = var.zone
  version_label            = var.version_label
  device_name_1            = var.device_name_1
  device_name_1_zone       = var.device_name_1_zone
  device_name_2            = var.device_name_2
  device_name_2_zone       = var.device_name_2_zone
  device_name_3            = var.device_name_3
  device_name_3_zone       = var.device_name_3_zone
  machine_type             = var.machine_type
  os_image                 = var.os_image
  service_account_email    = var.service_account_email
  service_account_scopes   = var.service_account_scopes
  network_name             = var.network_name
  firewall_ssh_name        = var.firewall_ssh_name
  firewall_ssh_description = var.firewall_ssh_description
  allow_protocol           = var.allow_protocol
  allow_ports              = var.allow_ports
}

