#!/bin/bash

# Prompt for MySQL password
read -s -p "Enter MySQL password: " mysql_password
echo

# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# Backup ownCloud database
sudo mysqldump -e -p"$mysql_password" owncloud > owncloud_backup.sql

# Borg backup
sudo borg create --compression auto,lzma -e repokey-blake2 group-c@backup-c:/home/group-c/full_backups::owncloud_backup_$current_date owncloud_backup.sql --stats

# Remove local backup file if necessary
# sudo rm owncloud_backup.sql


# sudo mysqldump -e -p owncloud > owncloud_backup.sql
# sudo mysqldump -e -p --all-databases > db_backupv2.sql