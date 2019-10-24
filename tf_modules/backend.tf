terraform {
  backend "gcs" {
    bucket = "iot-python-webapp-demo-secure-bucket-tfstate"
  }
}
