#!/bin/bash

# Log file path
log_file="/home/group-c/app_backup.log"
storage_server="20.211.153.89"
backup_server="backup-c"
user="group-c"


# Function to log messages to console and file
log_message() {
    echo "$1" | tee -a "$log_file"
}

# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# Generate backup file name with date
backup_file="appbackup_$current_date.tar.gz"

# Create backup archive
log_message "Creating backup archive..."
sudo tar -cvzf "$backup_file" --directory=/etc . 2>&1 | tee -a "$log_file"
tar_exit_code=${PIPESTATUS[0]}

# Check if tar command succeeded
if [ $tar_exit_code -ne 0 ]; then
    log_message "Error: tar command failed with exit code $tar_exit_code"
    exit 1
fi

# Transfer backup file using rsync
log_message "Transferring backup file using rsync..."

sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_app_backup" "$backup_file" $user@$backup_server:~/App_backup/ 2>&1 | tee -a "$log_file"
sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_app_backup" "$backup_file" $user@$storage_server:~/app-c/ 2>&1 | tee -a "$log_file"
rsync_exit_code=${PIPESTATUS[0]}

# Check if rsync command succeeded
if [ $rsync_exit_code -ne 0 ]; then
    log_message "Error: rsync command failed with exit code $rsync_exit_code"
    exit 1
fi

# Cleanup: Remove backup file after successful transfer
sudo rm "$backup_file"

log_message "Backup process completed successfully."
