#!/bin/bash

# Prompt for MySQL password
read -s -p "Enter MySQL password: " mysql_password
echo

# Server credentials
remote_username="group-c"
remote_server="10.2.0.5" # you can also use the hostname "backup-c"
remote_directory="~/"

# Get list of databases
databases=$(sudo mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Iterate over each database and create a backup file
for db in $databases; do
    # Create backup file
    sudo mysqldump "$db" > "$db.sql"
    
    # Transfer backup file to remote server using SCP
    sudo scp "$db.sql" "$remote_username"@"$remote_server":"$remote_directory"
    
    # Remove local backup file
    sudo rm "$db.sql"
done


# sudo mysqldump -e -p owncloud > owncloud_backup.sql
# sudo mysqldump -e -p --all-databases > db_backupv2.sql