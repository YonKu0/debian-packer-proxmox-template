#!/bin/bash
# Harden cloud-init VM template script
# This script hardens a Proxmox cloud-init VM on the first boot.

# Step 0: Set non-interactive mode to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Step 1: Disable root login and lock the root password
echo "Locking root password..."
passwd -l root

# Step 2: Harden SSH configuration
echo "Hardening SSH configuration..."
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords yes/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/^#LoginGraceTime 2m/LoginGraceTime 30s/' /etc/ssh/sshd_config
systemctl reload sshd

# Step 3: Set up firewall with UFW
echo "Configuring firewall with UFW..."
apt install -y ufw
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
ufw allow ssh
ufw allow 80    # Allow HTTP
ufw allow 443   # Allow HTTPS

# Enable UFW without prompts
ufw --force enable

# Step 4: Enable automatic security updates
echo "Enabling automatic security updates..."
apt install -y unattended-upgrades
dpkg-reconfigure --frontend=noninteractive unattended-upgrades

# Ensure unattended-upgrades service is enabled and started
systemctl enable --now unattended-upgrades
timeout 30 systemctl restart unattended-upgrades
systemctl status unattended-upgrades --no-pager

# Step 5: Enable audit logging
echo "Enabling auditd for security logging..."
apt install -y auditd
systemctl enable --now auditd
timeout 30 systemctl restart auditd

# Verify auditd status
systemctl status auditd --no-pager

# Step 6: Harden sysctl settings for network security
echo "Applying sysctl hardening..."
cat <<EOF >> /etc/sysctl.conf
# Prevent IP Spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP broadcasts and bad packets
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Enable TCP SYN cookies to prevent SYN flood attacks
net.ipv4.tcp_syncookies = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Protect against common network attacks
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_timestamps = 0
EOF
sysctl -p

# Verify sysctl settings
echo "Verifying sysctl settings..."
sysctl -a | grep -E 'rp_filter|icmp_echo_ignore|syncookies|log_martians|tcp_rfc1337|tcp_timestamps'

# Step 7: Restrict access to /tmp
echo "Securing /tmp directory..."
mount -o remount,noexec,nosuid /tmp
chmod 1777 /tmp

# Step 8: Set up log rotation and monitoring
echo "Setting up log rotation..."
apt install -y logrotate
logrotate /etc/logrotate.conf

# Step 9: Clean up unnecessary packages
echo "Cleaning up..."
apt autoremove -y
apt clean

# Final message
echo "Hardened cloud-init VM setup completed."
