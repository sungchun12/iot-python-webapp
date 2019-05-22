provider "google" {
  project = "${var.project}"
  region  = "${var.location}"
  zone    = "us-central1-c"
}

module "storage" {
  source  = "./modules/storage"
  version = "0.0.1"

  # pass the root module variables to child module
  project  = "${var.project}"
  location = "${var.location}"
}

module "data_pipeline" {
  source  = "./modules/data_pipeline"
  version = "0.0.1"

  # pass the root module variables to child  module
  project  = "${var.project}"
  location = "${var.location}"
}
