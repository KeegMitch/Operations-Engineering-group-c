#!/bin/bash

# Define source and destination directories
SOURCE_DIR="group-c@20.211.153.89:/home/group-c/app-c/"
DEST_DIR="/home/group-c/app-c/"

# Function to handle errors
handle_error() {
    local message="$1"
    echo "Error: $message" >&2
    exit 1
}

# Function to check if a command is available
check_command() {
    local command_name="$1"
    if ! command -v "$command_name" &> /dev/null; then
        handle_error "$command_name is not installed or not in the PATH."
    fi
}

# Function to check if a service is active
check_service() {
    local service_name="$1"
    if ! systemctl is-active --quiet "$service_name"; then
        handle_error "$service_name is installed but not running."
    fi
}

# Run rsync to grab the latest backup
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR" || handle_error "Failed to rsync backup from storage server."

# Uncompress the latest backup
cd "$DEST_DIR" || handle_error "Failed to change directory to $DEST_DIR."
sudo tar -xzvf "$(ls -t | head -n1)" -C ./ || handle_error "Failed to uncompress backup."

# Check if Puppet is installed and working
check_command "puppet"
if ! puppet agent --test &> /dev/null; then
    handle_error "Puppet is installed but not functioning correctly."
fi

# Check if MySQL client is installed and running
check_command "mysql"
check_service "mysql"

# Check if PHP 7.4 is installed and Apache2 is running
check_command "php7.4"
check_command "apache2"
check_service "apache2"

echo "Backup retrieval and setup completed successfully."
