terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.29.0"
    }
  }
}

provider "google" {
  project = "birkbeck-ccp-01"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "default" {
  name         = "vm-price-app"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts/ubuntu-2004-focal-v20220712"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "firewall-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
