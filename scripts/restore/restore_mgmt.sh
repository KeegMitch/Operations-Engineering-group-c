#!/bin/bash

# Define destination directories
puppet_dir="/etc/puppetlabs/"
user="group-c"
storage_server="20.211.153.89"

# Define the directory for storing logs
log_dir="$HOME/logs"
log_file="$log_dir/rsync_restore_puppetconf.log"

# Create the logs directory if it doesn't exist
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Function to log messages
log_message() {
    echo "$1" | tee -a "$log_file"
}

# Get the latest backup file from the storage server
log_message "Getting the latest backup file from the storage server..."
latest_backup=$(ssh -i /home/group-c/.ssh/id_rsa_offsite $user@$storage_server 'ls -t ~/mgmt-c/RSYNCpuppetbackup_*.tar.gz | head -n 1')

# Check if the latest_backup is not empty
if [ -z "$latest_backup" ]; then
    log_message "Error: No backup files found on the storage server."
    exit 1
fi

log_message "Latest backup file found: $latest_backup"

# Restore the Puppet configuration from the latest backup file
log_message "Restoring Puppet configuration from the latest backup file..."
sudo tar -xzvf "$latest_backup" -C "$puppet_dir" >> "$log_file"

# Check if the restore process was successful
if [ $? -eq 0 ]; then
    log_message "Puppet configuration restored successfully."
else
    log_message "Error: Failed to restore Puppet configuration."
    exit 1
fi


# Add this: install puppet server on mgmt server as it will most likely not be installed on a new server


if ! wget --spider -q https://apt.puppetlabs.com/puppet6-release-bionic.deb; then
    echo "Failed to download puppet6-release-bionic.deb"
    exit 1
else
    echo "puppet6-release-bionic.deb downloaded successfully"
fi

sudo wget -q https://apt.puppetlabs.com/puppet6-release-bionic.deb

if dpkg-query -l puppet6-release-bionic &>/dev/null; then
    echo "puppet6-release-bionic is already installed"
else
    sudo dpkg -i puppet6-release-bionic.deb
fi

sudo apt-get update


if dpkg-query -l puppetserver &>/dev/null; then
    echo "puppetserver is already installed"
else
    sudo apt-get install -y puppetserver
fi

if systemctl is-active --quiet puppetserver; then
    echo "puppetserver is already running"
else
    sudo systemctl start puppetserver
fi
