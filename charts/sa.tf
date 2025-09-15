provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "vm_instance" {
  name         = var.name
  project      = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  deletion_protection = var.deletion_protection

  metadata = var.metadata

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.bootdisk_size
      type  = var.disk
    }
  }

  network_interface {
    network    = data.google_compute_network.vpc_network.self_link
    subnetwork = data.google_compute_subnetwork.vpc_subnet.self_link

    access_config {
      // This block enables external IP
    }
  }

  service_account {
    email  = data.google_service_account.compute_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}


project_id          = "my-gcp-project"
region              = "us-central1"
zone                = "us-central1-a"
name                = "my-debian12-vm"
machine_type        = "e2-medium"
bootdisk_size       = 20
disk                = "pd-balanced"
deletion_protection = false

metadata = {
  startup-script = "echo Hello, World from Debian 12 > /var/tmp/startup.txt"
}

network             = "default"
subnet              = "default"
service_account_id  = "my-vm-sa"

variable "name"{
    type = string
}
 
variable "machine_type"{
    type = string
}
 
variable "zone"{
    type = string
}

variable "region"{
    type = string
}

variable "metadata"{
    type = map(string)
}

variable "bootdisk_size"{
    type = string
}

variable "disk"{
    type = string
}

variable "project_id"{
    type = string
}

variable "service_account"{
    type = string
}

variable "image"{
    type = string
}

variable "network"{
    type = string
}

variable "subnet"{
    type = string
}

variable "host_project_id"{
    type = string
}

variable "deletion_protection"{
    type = bool
}

variable "additional_disks" {
  description = "List of additional persistent disks to attach to the instance"
  type = list(object({
    device_name = string
    mode        = string # READ_WRITE or READ_ONLY
    disk_type   = string
    disk_size   = number
  }))
  default = []
}
