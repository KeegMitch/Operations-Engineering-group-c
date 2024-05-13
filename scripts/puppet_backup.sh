#!/bin/bash

# Define source directories
puppet_dir="/etc/puppetlabs/"
# modules_dir="/etc/puppetlabs/code/modules"
# site_pp="/etc/puppetlabs/code/environments/production/manifests/site.pp"

# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# Define archive filename
archive_name="puppetbackup_$current_date.tar.gz"

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
sudo tar -czvf "$backup_dir/$archive_name" "$puppet_dir"

if [[ $? -eq 0 ]]; then
echo "Backup created: $backup_dir/$archive_name"

fi

# automated by the sudo crontab as well that runs every day at 6pm NZT / 6am UTC

# following commands in sudo crontab:
# HOME=/home/group-c
# 0 6 * * * home/group-c/puppet_backup.sh > logfile.log
