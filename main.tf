provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

terraform {
  backend "gcs" {
    bucket = var.tf_state_bucket
    prefix = "terraform/state"
  }
}

# Create a GCS bucket
resource "google_storage_bucket" "default" {
  name     = "${var.project_id}-infra-bucket"
  location = var.region
}

# Create a custom VPC
resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

# Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
}

# Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  private_ip_google_access = true
}

# VM instance using Ubuntu and attached to the public subnet
resource "google_compute_instance" "vm_instance" {
  name         = "vm-${var.environment}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork    = google_compute_subnetwork.public_subnet.id
    access_config {}  # Needed for external IP
  }

  tags = ["vm-public"]
}
