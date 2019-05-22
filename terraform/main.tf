provider "google" {
  project = "${var.project}"
  region  = "${var.location}"
  zone    = "us-central1-c"
}

module "storage" {
  source  = "./modules/storage"
  version = "0.0.1"

  # pass the root module variables to child storage module
  project  = "${var.project}"
  location = "${var.location}"
}
