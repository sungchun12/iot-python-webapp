terraform {
  backend "gcs" {
    bucket = "wam-bam-258119-secure-bucket-tfstate"
  }
}
