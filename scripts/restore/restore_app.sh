#!/bin/bash

# Variables
log_file="/home/group-c/app_restore.log"
storage_server="20.211.153.89"
user="group-c"
local_backup_path="/home/group-c/app_server_backups"
extract_path="/home/group-c/app_server_backups/extracted"

sudo mkdir -p $local_path
sudo mkdir -p $extract_path


# Function to log messages
log_message() {
    echo "$1" | tee -a "$log_file"
}

# Step 1: Find the latest backup file
log_message "Finding the latest backup file..."
latest_backup=$(ssh -i /home/group-c/.ssh/id_rsa_app_storage $user@$storage_server 'ls -t ~/app-c/appbackup_*.tar.gz | head -n 1')

# Check if the latest_backup is not empty
if [ -z "$latest_backup" ]; then
    log_message "Error: No backup files found."
    exit 1
fi

log_message "Latest backup file found: $latest_backup"

# Step 2: Transfer the latest backup file
log_message "Transferring the latest backup file..."
sudo scp -i /home/group-c/.ssh/id_rsa_app_storage $user@$storage_server:"$latest_backup" $local_path/


# Check if scp command succeeded
scp_exit_code=$?
if [ $scp_exit_code -ne 0 ]; then
    log_message "Error: scp command failed with exit code $scp_exit_code"
    exit 1
fi

# Step 3: Decompress the tar file
latest_backup_file=$(basename "$latest_backup")
log_message "Decompressing the tar file: $latest_backup_file..."
sudo tar -xzvf $local_path/"$latest_backup_file" -C $extract_path/

# Check if tar command succeeded
tar_exit_code=$?
if [ $tar_exit_code -ne 0 ]; then
    log_message "Error: tar command failed with exit code $tar_exit_code"
    exit 1
fi

# Step 4: Use rsync to restore the files
log_message "Restoring the files using rsync..."
sudo rsync -avh $extract_path/ /etc/

# Step 5: Reinstall dependencies if puppet does not work

# Check if rsync command succeeded
rsync_exit_code=$?
if [ $rsync_exit_code -ne 0 ]; then
    log_message "Error: rsync command failed with exit code $rsync_exit_code"
    exit 1
fi

log_message "Restore process completed successfully."

