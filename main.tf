provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket  = var.tf_state_bucket
    prefix  = "terraform/state"
  }
}

resource "google_storage_bucket" "default" {
  name     = "${var.project_id}-infra-bucket"
  location = var.region
}

resource "google_compute_instance" "vm_instance" {
  name         = "vm-${var.environment}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }
}
