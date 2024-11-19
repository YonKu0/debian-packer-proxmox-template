packer {
  required_plugins {
    name = {
      version = "1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
variable "bios_type" {
  type = string
}
variable "boot_command" {
  type = string
}
variable "boot_wait" {
  type = string
}
variable "bridge_firewall" {
  type = bool
}
variable "bridge_name" {
  type = string
}
variable "cloud_init" {
  type = bool
}
variable "iso_file" {
  type = string
}
variable "iso_url" {
  type = string
}
variable "iso_checksum" {
  type = string
}
variable "machine_default_type" {
  type = string
}
variable "network_model" {
  type = string
}
variable "os_type" {
  type = string
}
variable "proxmox_api_token_id" {
  type = string
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
variable "proxmox_api_url" {
  type = string
}
variable "proxmox_node" {
  type = string
}
variable "qemu_agent_activation" {
  type = bool
}
variable "scsi_controller_type" {
  type = string
}
variable "ssh_timeout" {
  type = string
}
variable "tags" {
  type = string
}
variable "io_thread" {
  type = bool
}
variable "cpu_type" {
  type = string
}
variable "vm_info" {
  type = string
}
variable "vm_id" {
  type = string
}
variable "disk_discard" {
  type = bool
}
variable "disk_format" {
  type = string
}
variable "disk_size" {
  type = string
}
variable "disk_type" {
  type = string
}
variable "num_cores" {
  type = number
}
variable "num_cpu" {
  type = number
}
variable "memory_size" {
  type = number
}
variable "ssh_username" {
  type = string
}
variable "ssh_password" {
  type = string
}
variable "ssh_handshake_attempts" {
  type = number
}
variable "storage_pool" {
  type = string
}
variable "packer_host_ip" {
  type = string
}
variable "packer_host_port" {
  type = string
}
variable "vm_name" {
  type = string
}
locals {
  packer_timestamp = formatdate("YYYYMMDD-hhmm", timestamp())
}

source "proxmox-iso" "debian12" {

  # Proxmox API and HTTP Configuration
  node                     = "${var.proxmox_node}"
  token                    = "${var.proxmox_api_token_secret}"
  username                 = "${var.proxmox_api_token_id}"
  proxmox_url              = "${var.proxmox_api_url}"
  http_bind_address        = "${var.packer_host_ip}"
  http_port_min            = "${var.packer_host_port}"
  http_port_max            = "${var.packer_host_port}"
  http_directory           = "./"
  insecure_skip_tls_verify = true

  # Packer SSH settings
  ssh_username           = "${var.ssh_username}"
  ssh_password           = "${var.ssh_password}"
  ssh_handshake_attempts = "${var.ssh_handshake_attempts}"
  ssh_timeout            = "${var.ssh_timeout}"
  communicator           = "ssh"
  ssh_pty                = true

  # Cloud-Init and QEMU Agent
  bios                    = "${var.bios_type}"
  boot_command            = ["${var.boot_command}"]
  boot_wait               = "${var.boot_wait}"
  qemu_agent              = "${var.qemu_agent_activation}"
  cloud_init              = "${var.cloud_init}"
  cloud_init_storage_pool = "${var.storage_pool}"

  # VM Configuration
  cores           = "${var.nb_core}"
  memory          = "${var.nb_ram}"
  cpu_type        = "${var.cpu_type}"
  machine         = "${var.machine_default_type}"
  os              = "${var.os_type}"
  scsi_controller = "${var.scsi_controller_type}"
  sockets         = "${var.nb_cpu}"
  tags            = "${var.tags}"

  # VM Metadata
  vm_id                = "${var.vm_id}"
  vm_name              = "${var.vm_name}"
  template_description = "${var.vm_info} - ${local.packer_timestamp}"

  # ISO Configuration
  boot_iso {
    type             = "${var.disk_type}"
    iso_url          = "${var.iso_url}"
    iso_checksum     = "${var.iso_checksum}"
    iso_storage_pool = "local"
    unmount          = true
    iso_download_pve = true
  }

  # Or use local ISO file (comment the remote ISO block above)
  # boot_iso {
  #   unmount      = true
  #   iso_file     = "${var.iso_file}"
  #   type         = "${var.disk_type}"
  #   iso_checksum = "${var.iso_checksum}"
  # }

  # Disk Configuration
  disks {
    discard      = "${var.disk_discard}"
    disk_size    = "${var.disk_size}"
    format       = "${var.disk_format}"
    io_thread    = "${var.io_thread}"
    storage_pool = "${var.storage_pool}"
    type         = "${var.disk_type}"
    ssd          = true
  }

  # Network Configuration
  network_adapters {
    bridge   = "${var.bridge_name}"
    firewall = "${var.bridge_firewall}"
    model    = "${var.network_model}"
  }
}


build {
  # Sources: Specify the ISO source for the build
  sources = ["source.proxmox-iso.debian12"]

  # Shell Provisioners
  # 1. Install Docker
  provisioner "shell" {
    script = "scripts/install_docker.sh"
  }

  # 2. Apply System Hardening
  provisioner "shell" {
    script = "scripts/hardening.sh"
  }

  # Cloud-Init Configuration Files
  # Use these provisioners to upload cloud-init configuration files to the VM.
  # These files specify datasource options for cloud-init.

  # provisioner "file" {
  #   source      = "99_pve.cfg"
  #   destination = "/etc/cloud/cloud.cfg.d/99_pve.cfg"
  # }

  # provisioner "file" {
  #   source      = "cloud.cfg"
  #   destination = "/etc/cloud/cloud.cfg"
  # }
}