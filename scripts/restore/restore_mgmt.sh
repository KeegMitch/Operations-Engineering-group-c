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
