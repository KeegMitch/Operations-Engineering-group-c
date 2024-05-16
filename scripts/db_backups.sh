#!/bin/bash

# Prompt for MySQL password, which we need to automate
# read -s -p "Enter MySQL password: " mysql_password
# echo

source "$HOME/.env"

# Retrieve MySQL password from environment variable
mysql_password="$MYSQL_PASSWORD"

# Check if MySQL password environment variable is set
if [ -z "$mysql_password" ]; then
    echo "Error: MySQL password environment variable not set. Please set the MYSQL_PASSWORD environment variable before running the script." >&2
    exit 1
fi

log_file="dbbackup_log.log"


# Server credentials
remote_username="group-c"
backup_server="10.2.0.5" # private ip of backup-c
backup_host="backup-c"

storage_server="20.211.153.89"
storage_host="offsite"

remote_directory="/home/$remote_username/database_backup"
storage_directory="/home/$remote_username/db-c"


# Get list of databases
databases=$(sudo mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Function to handle errors
handle_error() {
    echo "Error: $1"
	echo "$(date +"%Y-%m-%d %H:%M:%S") - Error: $1" >> "$log_file"
    exit 1
}

# Another function to handle log messages for said errors
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$log_file"
}

# Initialize log file
echo "Backup Log $(date +"%Y-%m-%d %H:%M:%S")" > "$log_file"


# Iterate over each database and create a backup file
for db in $databases; do

 # Create backup file
    sudo mysqldump "$db" -p"$mysql_password" > "$db.sql" || handle_error "Failed to create MySQL dump for database $db"
    log_message "Created MySQL dump for database $db"

    # Rsync to BACKUP server
    if sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_db_1" "$HOME/$db.sql" "$remote_username@$backup_host:$remote_directory/"; then
        log_message "Rsynced backup to $backup_host"
        # Remove local backup file if rsync succeeded
        sudo rm "$db.sql" || handle_error "Failed to remove local backup file $db.sql"
        log_message "Removed local backup file $db.sql"
    else
        handle_error "Failed to rsync backup to $backup_host"
    fi

    # Rsync to STORAGE server (commented out for testing)
    #if ! sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_db_offsite" "$HOME/$db.sql" "$remote_username@$storage_host:$storage_directory/"; then
    #    handle_error "Failed to rsync backup to $storage_host"
    #fi
    #log_message "Rsynced backup to $storage_host"

	
done

echo "Backup process completed successfully"
log_message "Backup process completed successfully"

# Manual testing commands 
# sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_db_1" "$HOME/owncloud.sql" group-c@backup-c:~
# sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_db_offsite" "$HOME/owncloud.sql" group-c@20.211.153.89:~/db-c

# sudo mysqldump -e -p owncloud > owncloud_backup.sql
# sudo mysqldump -e -p --all-databases > db_backupv2.sql