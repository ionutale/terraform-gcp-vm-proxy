terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.89.0"
    }
  }
}

provider "google" {
  project = "steel-wharf-330805"
  region  = "us-central1"
  zone    = "us-central1-c"
}



resource "google_compute_instance" "vm_proxy" {
  name                      = "vm_proxy"
  machine_type              = "f1-micro"
  allow_stopping_for_update = false
  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2004-lts"
    }
  }
  
  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_tr_network.self_link
    access_config {
    }
  }

  metadata_startup_script = "${file("./script.sh")}"

}

resource "google_compute_network" "vpc_proxy_vm" {
  name                    = "proxy_vm"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-tunnel" {
  name    = "ssh-tunnel"
  network = google_compute_network.vpc_proxy_vm.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  #target_tags = ["terraform-instance"]
  source_ranges = ["0.0.0.0/0"]
}
