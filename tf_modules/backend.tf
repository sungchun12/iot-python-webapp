terraform {
  backend "gcs" {
    bucket = "PROJECT_ID-secure-bucket-tfstate"
  }
}
