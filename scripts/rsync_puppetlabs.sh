#!/bin/bash

# Define source directories
puppet_dir="/etc/puppetlabs/"
# modules_dir="/etc/puppetlabs/code/modules"
# site_pp="/etc/puppetlabs/code/environments/production/manifests/site.pp"

# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# create backup
log_dir="$HOME/logs"
log_file="$log_dir/rsync_puppetconf.log"

if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Define archive filename
archive_name="RSYNCpuppetbackup_$current_date.tar.gz"

# Create the mgmt_backups directory if it doesn't exist 
backup_dir="$HOME/rsync_backup"

if [ ! -d "$backup_dir" ]; then
    # Create the directory
    sudo mkdir -p "$backup_dir"
	echo "Check manual_puppetconf.log for output"
    echo "Directory $backup_dir created." >> $log_file
else
	echo "Check manual_puppetconf.log for output"
    echo "Directory $backup_dir already exists. Backing up puppet config ..." >> $log_file
fi

# Create a compressed tar archive directly from source files
# sudo tar -czvf "$HOME/mgmt_backups/$archive_name" "$modules_dir" "$site_pp"
sudo tar -czvf "$backup_dir/$archive_name" "$puppet_dir" >> $log_file


# rsync into backup server

sudo rsync -av --link-dest=/home/group-c/rsync_backup -e "ssh -i /home/group-c/.ssh/id_rsa" /etc/puppetlabs group-c@backup-c:~/rsync_backup

# rsync into storage server



exit_status=$?

if [[ $? -eq 0 ]]; then
echo "Backup created: Check rsync_puppetconf.log for output"
echo "Backup created: $backup_dir/$archive_name" >> $log_file
else
  echo "Backup failed with exit code: $exit_status , Check rsync_puppetconf.log for output"
  echo "Backup failed with exit code: $exit_status" >> $log_file
fi

# automated by the sudo crontab as well that runs every day at 7pm NZT / 7am UTC (cron changed to NZT)

# following commands in sudo crontab:
# HOME=/home/group-c
# 0 19 * * * home/group-c/puppet_backup.sh > /logs/cron.log
