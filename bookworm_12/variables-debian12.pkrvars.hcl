// General BIOS and Machine Settings
bios_type            = "seabios" // Type of BIOS to use for the VM (e.g., seabios, uefi).
machine_default_type = "q35"     // Default machine type for modern features.
cpu_type             = "host"    // Type of CPU to emulate in the VM.
os_type              = "l26"     // Operating system type (e.g., l26 for Linux).
num_cores            = 1         // Number of cores assigned to the VM.
num_cpu              = 1         // Number of CPUs (sockets) assigned to the VM.
memory_size          = 2048      // RAM size in MB.


// Disk Configuration
disk_discard         = true              // Enable discard/TRIM for the VM disk.
disk_format          = "raw"             // Format of the VM disk (e.g., raw, qcow2).
disk_size            = "12G"             // Size of the VM disk.
disk_type            = "scsi"            // Disk interface type (e.g., scsi, virtio).
scsi_controller_type = "virtio-scsi-pci" // SCSI controller type (e.g., virtio-scsi-pci).


// ISO and Boot Configuration
iso_file     = "local:iso/debian-12.8.0-amd64-netinst.iso"                                                                                                                                        // Path to the ISO file on the Proxmox server.
iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"                                                                                        // URL for downloading the ISO.
iso_checksum = "f4f7de1665cdcd00b2e526da6876f3e06a37da3549e9f880602f64407f602983a571c142eb0de0eacfc9c1d0f534e9339cdce04eb9daddc6ddfa8cf34853beed"                                                 // Checksum of the ISO file.
boot_command = "<esc><wait>auto console-keymaps-at/keymap=fr console-setup/ask_detect=false debconf/frontend=noninteractive fb=false url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>" // Command for automated installation.
boot_wait    = "5s"                                                                                                                                                                               // Time to wait before booting the VM.


// Network Configuration
bridge_name     = "vmbr0"  // Name of the bridge interface on Proxmox.
bridge_firewall = false    // Whether to enable the Proxmox firewall on the bridge.
network_model   = "virtio" // Network adapter model (e.g., virtio, e1000).
io_thread       = false    // Enable or disable IO threads for the VM.


// Cloud-Init and QEMU Agent
cloud_init            = true // Enable cloud-init support for provisioning.
qemu_agent_activation = true // Enable QEMU guest agent for better VM management.


// Proxmox API and Host Settings
proxmox_node             = "pve"                                  // Proxmox node where the VM will be created.
proxmox_api_token_id     = "packer@pam!packer"                    // API token ID for accessing Proxmox.
proxmox_api_token_secret = "e676dfb0-6d7c-4aec-9fc6-62f1d2b976f1" // API token secret for authentication.
proxmox_api_url          = "https://192.168.1.190:8006/api2/json" // Proxmox API URL for making requests.
packer_host_ip           = "192.168.1.119"                        // IP address of the machine running Packer.
packer_host_port         = 8802                                   // Port of the machine running Packer.


// SSH Configuration
ssh_username           = "root"   // SSH username for VM access (set in preseed.cfg).
ssh_password           = "packer" // SSH password for VM access (set in preseed.cfg).
ssh_handshake_attempts = 6        // Number of SSH handshake attempts.
ssh_timeout            = "20m"    // Timeout for SSH connection.


// VM Metadata
vm_id   = 9000                        // Unique identifier for the VM.
vm_info = "Debian 12 Packer Template" // Description of the VM template.
vm_name = "packer-debian-12"          // Name of the VM.
tags    = "template"                  // Tags to categorize the VM (e.g., 'template').


// Storage Pool
storage_pool = "local-zfs" // Storage pool to use for the VM.
