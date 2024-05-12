#!/bin/bash

# Define source directories
puppet_dir="/etc/puppetlabs/"
# modules_dir="/etc/puppetlabs/code/modules"
# site_pp="/etc/puppetlabs/code/environments/production/manifests/site.pp"

# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# Define archive filename
archive_name="puppetbackup_$current_date.tar.gz"

# Define remote server details
remote_username="group-c"
remote_host="backup-c"
remote_directory="~/"

# Create the mgmt_backups directory if it doesn't exist
backup_dir="$HOME/mgmt_backups"

if [ ! -d "$backup_dir" ]; then
    # Create the directory
    sudo mkdir -p "$backup_dir"
    echo "Directory $backup_dir created."
else
    echo "Directory $backup_dir already exists. Backing up puppet config ..."
fi

# Create a compressed tar archive directly from source files
# sudo tar -czvf "$HOME/mgmt_backups/$archive_name" "$modules_dir" "$site_pp"
sudo tar -czvf "$HOME/mgmt_backups/$archive_name" "$puppet_dir"

if [[ $? -eq 0 ]]; then
echo "Backup created: $HOME/mgmt_backups/$archive_name"
 # Copy the backup archive to the remote server
    echo "Copying backup archive to remote server..."
    sudo scp "$HOME/mgmt_backups/$archive_name" "$remote_username@$remote_host:$remote_directory"
    
    if [[ $? -eq 0 ]]; then
        echo "Backup archive copied to remote server."
    else
        echo "Failed to copy backup archive to remote server."
    fi

fi



# automated by the crontab as well that runs every day at 9:15am (testing)
# 15 9 * * * ~/puppet_backup.sh

# Calculate the size of the archive (relevant for git repositories as there's a 100MB size limit per git commit)
# size=$(sudo du -h "$HOME/mgmt_backups/$archive_name" | cut -f1)
# echo "Archive size: $size"