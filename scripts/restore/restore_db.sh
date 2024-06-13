#!/bin/bash

# Define source and destination directories
SOURCE_DIR="group-c@20.211.153.89:/home/group-c/db-c/"
DEST_DIR="/home/group-c/db-c/"
log_file="/var/log/db_restore.log"

# Step 1: Run rsync to grab the latest backup
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR" || { echo "Failed to sync backup from remote server."; exit 1; }

# Function to handle errors
handle_error() {
    echo "Error: $1" >&2
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: $1" >> "$log_file"
    exit 1
}

# Prompt for MySQL root password
read -rsp "Enter MySQL root password: " mysql_password
echo

# Loop through each backup file
for backup_file in "${@:2}"; do
    # Check if the backup file exists
    [ -f "$backup_file" ] || { echo "Backup file does not exist: $backup_file"; exit 1; }

    # Create the database if it doesn't exist
    sudo mysql -u root -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS $1;" || handle_error "Failed to create database $1."

    # Restore the database from the backup file
    sudo mysql -u root -p"$mysql_password" "$1" < "$backup_file" || handle_error "Failed to restore database $1 from $backup_file."

    echo "Database restoration completed successfully for $1 from $backup_file."
done > "$log_file"

echo "Restore Log $(date +"%Y-%m-%d %H:%M:%S")" >> "$log_file"



