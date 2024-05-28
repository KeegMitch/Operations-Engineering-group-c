#!/bin/bash

# Nagios directories

nagios_dir="/etc/nagios3"
nagios_plugins="/etc/nagios-plugins"

user="group-c"
backup_server="backup-c"
storage_server="20.211.153.89"


# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# create backup
log_dir="$HOME/logs"
log_file="$log_dir/rsync_nagios.log"

if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Define archive filename
archive_name="nagiosbackup_$current_date.tar.gz"

# Create the puppet_backups directory if it doesn't exist
backup_dir="$HOME/nagios_backups"

if [ ! -d "$backup_dir" ]; then
    # Create the directory
    sudo mkdir -p "$backup_dir"
	echo "Directory $backup_dir created."
    echo "Directory $backup_dir created." >> $log_file
else
    echo "Directory $backup_dir already exists. Backing up puppet config ..."    
    echo "Directory $backup_dir already exists. Backing up puppet config ..." >> $log_file
fi

# Create a compressed tar archive directly from source files
sudo tar -czvf "$backup_dir/$archive_name" "$nagios_dir" "$nagios_plugins" >> $log_file

# rsync into storage server

rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_offsite" "$backup_dir" $user@$storage_server:~/mgmt-c/

# rsync into backup server(for testing only)
rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa" "$backup_dir" $user@$backup_server:~/mgmt_backups/

exit_status=$?

if [[ $? -eq 0 ]]; then
echo "Backup created: $backup_dir/$archive_name"
echo "Backup created: $backup_dir/$archive_name" >> $log_file
else
  echo "Backup failed with exit code: $exit_status , Check rsync_puppetconf.log for output"
  echo "Backup failed with exit code: $exit_status" >> $log_file
fi



# following commands in sudo crontab (runs 4 times a day or every 6 hours):
# HOME=/home/group-c
# 45 1,7,13,19 * * * home/group-c/rsync_nagios.sh > /logs/nagios_cron.log

