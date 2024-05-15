#!/bin/bash

# Prompt for MySQL password
read -s -p "Enter MySQL password: " mysql_password
echo

# Server credentials
remote_username="group-c"
remote_server="backup-c" # you can also use the private ip 
remote_directory="~/"

# Get list of databases
databases=$(sudo mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Iterate over each database and create a backup file
for db in $databases; do
    # Create backup file
    sudo mysqldump "$db" > "$db.sql"
    

 # Transfer backup file to remote server using rsync
	sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa" "~/$db.sql" "$remote_username"@"$remote_server":"$remote_directory"
	
	# sudo rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa" "~/owncloud.sql" group-c@backup-c:~/
	# sudo rsync -av ~/owncloud.sql group-c@backup-c:~/
	
	# scp just for testing
	sudo scp 
    
    # Remove local backup file
    sudo rm "$db.sql"
done


# sudo mysqldump -e -p owncloud > owncloud_backup.sql
# sudo mysqldump -e -p --all-databases > db_backupv2.sql