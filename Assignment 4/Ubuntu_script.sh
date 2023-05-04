#!/bin/bash

# Update the system and install necessary packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y ufw auditd fail2ban libpam-cracklib libpam-tmpdir

# Configure the firewall (allow only necessary ports)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# Configure the auditd service
sudo sed -i 's/.*max_log_file.*/max_log_file = 50/' /etc/audit/auditd.conf
sudo sed -i 's/.*space_left.*/space_left = 75/' /etc/audit/auditd.conf
sudo sed -i 's/.*action_mail_acct.*/action_mail_acct = root/' /etc/audit/auditd.conf
sudo sed -i 's/.*action_mail.*/action_mail = /bin/true/' /etc/audit/auditd.conf
sudo sed -i 's/.*admin_space_left.*/admin_space_left = 50/' /etc/audit/auditd.conf
sudo systemctl restart auditd

# Configure fail2ban (prevent brute-force attacks)
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime = 10m/bantime = 1h/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure PAM (password policies)
sudo sed -i 's/pam_cracklib.so/pam_cracklib.so minlen=12 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
sudo sed -i 's/pam_unix.so/pam_unix.so remember=5/' /etc/pam.d/common-password

# Disable unused services and protocols
sudo systemctl disable cups.service
sudo systemctl disable bluetooth.service
sudo sed -i 's/Protocol 2,1/Protocol 2/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Configure the SSH service (disable password authentication)
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install and configure an antivirus software
sudo apt-get install -y clamav
sudo freshclam
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon

echo "Hardening script finished successfully!"
