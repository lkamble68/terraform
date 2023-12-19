provider "google" {
  credentials = file("account.json")
  project     = "heroic-climber-398110"
  region      = "us-central1"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

#resource "google_compute_network" "vpc_network" {
#  name = "terraform-network"
#}

#resource "google_compute_network" "vpc_network_custom" {
#  name = "terraform-network-custom"
#}

resource "google_compute_network" "vpc_my_custom" {
  name                    = "laxman-network-custome"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kamble_network" {
  ip_cidr_range = "10.1.0.0/24"
  name          = "subnet-a"
  network       = google_compute_network.vpc_my_custom.id
  region        = "us-central1"
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom-test.id
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_network" "custom-test" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_network_auto" {
  name = "terraform-network-auto"
}

resource "google_compute_subnetwork" "subnet_a" {
  ip_cidr_range = "10.2.0.0/16"
  name          = "my-auto-network"
  region        = "us-central1"
  network       = google_compute_network.vpc_network_auto.id
}


resource "google_compute_instance" "vm_instance" {
  machine_type = "f1-micro"
  tags         = ["web"]
  name         = "terraform-vm"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network_auto.id
    #    access_config {
    #      nat_ip = google_compute_address.stati
    #    }
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y ansible
  EOF
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_firewall" "tf_firewall" {
  name    = "terraform-firewall"
  network = google_compute_network.vpc_network_auto.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "22", "1000-2000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]

}


terraform {
  backend "gcs" {
    bucket      = "laxman-68"
    credentials = "account.json"
  }
}

variable "region" {
  default = "us-central1"
}

variable "machinetype" {
  default = "f1.micro"
}

variable "zone" {
  default = "us-central1-a"
}



