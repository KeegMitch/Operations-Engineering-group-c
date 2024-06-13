#!/bin/bash

# Define source and destination directories
SOURCE_DIR="group-c@20.211.153.89:/home/group-c/db-c/"
DEST_DIR="/home/group-c/db-c/"
log_file="/home/group-c/db_restore.log"

# Function to handle errors
handle_error() {
    echo "Error: $1" >&2
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: $1" >> "$log_file"
    exit 1
}

# Function to check and create log file if it doesn't exist
check_and_create_log_file() {
    if [ ! -f "$log_file" ]; then
        touch "$log_file" || handle_error "Failed to create log file: $log_file"
        echo "Created log file: $log_file"
    fi
}

# Function to check if Puppet is installed and install it if not
check_and_install_puppet() {
    if ! command -v puppet &> /dev/null; then
        echo "Puppet is not installed. Installing Puppet..."
        sudo apt update || handle_error "Failed to update package list."
        sudo apt install -y puppet || handle_error "Failed to install Puppet."
        echo "Puppet installed successfully."
    fi
}

# Function to check if MariaDB is installed and install it via Puppet if not
check_and_install_mariadb() {
    if ! command -v mariadb &> /dev/null; then
        echo "MariaDB is not installed. Installing MariaDB via Puppet..."
        sudo puppet apply -e 'package { "mariadb-server": ensure => installed }' || handle_error "Failed to install MariaDB via Puppet."
        echo "MariaDB installed successfully."
    fi
}

# Step 1: Run rsync to grab the latest backup
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR" || { echo "Failed to sync backup from remote server."; exit 1; }

# Prompt for MySQL root password
read -rsp "Enter MySQL root password: " mysql_password
echo

# Check and create log file if necessary (not working)
# check_and_create_log_file

# Check and install Puppet if necessary (not working)
# check_and_install_puppet

# Check and install MariaDB via Puppet if necessary (not working)
# check_and_install_mariadb

# Loop through each backup file
for backup_file in "${@:2}"; do
    # Check if the backup file exists
    [ -f "$backup_file" ] || { echo "Backup file does not exist: $backup_file"; exit 1; }

    # Create the database if it doesn't exist
    sudo mysql -u root -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS $1;" || handle_error "Failed to create database $1."

    # Restore the database from the backup file
    sudo mysql -u root -p"$mysql_password" "$1" < "$backup_file" || handle_error "Failed to restore database $1 from $backup_file."

    echo "Database restoration completed successfully for $1 from $backup_file."
done >> "$log_file"

echo "Restore Log $(date +"%Y-%m-%d %H:%M:%S")" >> "$log_file"
