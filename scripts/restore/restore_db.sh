#!/bin/bash

# Load environment variables
source "$HOME/.env"

# Retrieve MySQL password from environment variable
mysql_password="$MYSQL_PASSWORD"

# Check if MySQL password environment variable is set
if [ -z "$mysql_password" ]; then
    echo "Error: MySQL password environment variable not set. Please set the MYSQL_PASSWORD environment variable before running the script." >&2
    exit 1
fi

log_file="dbrestore_log.log"

# Function to handle errors
handle_error() {
    echo "Error: $1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: $1" >> "$log_file"
    exit 1
}

# Function to handle log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}


echo "Restore Log $(date +"%Y-%m-%d %H:%M:%S")" > "$log_file"

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <database_name> <backup_file>"
    exit 1
fi

db_name="$1"
backup_file="$2"

# Check if the backup file exists
if [ ! -f "$backup_file" ]; then
    handle_error "Backup file does not exist: $backup_file"
fi

# Create the database if it doesn't exist
log_message "Creating database $db_name if it does not exist."
sudo mysql -u root -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS $db_name;" || handle_error "Failed to create database $db_name."

# Restore the database from the backup file
log_message "Restoring database $db_name from $backup_file."
sudo mysql -u root -p"$mysql_password" "$db_name" < "$backup_file" || handle_error "Failed to restore database $db_name from $backup_file."

log_message "Successfully restored database $db_name from $backup_file."
echo "Database restoration completed successfully."
log_message "Database restoration completed successfully."

# run the script with arguments

# ./restore_db.sh owncloud ./owncloud.sql
