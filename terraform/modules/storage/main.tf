resource "google_storage_bucket" "data-store" {
  name = "iot-raw-data-sung"

  location      = "${var.location}"
  project       = "${var.project}"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  labels = {
    version = "demo"
  }
}

resource "google_storage_bucket" "dataflow-staging" {
  name = "iot-dataflow-stage-sung"

  location      = "${var.location}"
  project       = "${var.project}"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  labels = {
    version = "demo"
  }
}
