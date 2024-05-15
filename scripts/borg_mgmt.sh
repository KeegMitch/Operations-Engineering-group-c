#!/bin/bash

# mgmt server test borg with puppet config

#initialise the repo first

# sudo borg init --encryption repokey-blake2 /home/group-c/backup_name
# keep passphrase empty


# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# create backup logs
log_dir="$HOME/logs"
log_file="$log_dir/borg_puppetconf.log"

if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

sudo borg create --compression auto,lzma -e repokey-blake2 group-c@backup-c:/home/group-c/mgmt_backups::puppetbackup_$current_date /etc/puppetlabs/ >> "$log_file" 2>&1  --stats

# manual commands
# sudo borg create --compression auto,lzma -e repokey-blake2 group-c@backup-c:/home/group-c/mgmt_backups::puppetbackup_$(date +"%B_%d_%Y_%H%M%S") /etc/puppetlabs/ --stats
# sudo borg list group-c@backup-c:/home/group-c/mgmt_backups



# Capture the exit status of the borg create command
borg_exit_status=$?

# Check if the backup command exited successfully (exit code 0)
if [ $borg_exit_status -eq 0 ]; then
  echo "Backup completed successfully! Check borg_puppetconf.log for output"
  echo "Backup completed successfully!" >> $log_file
else
  echo "Backup failed with exit code: $borg_exit_status , Check borg_puppetconf.log for output"
  echo "Backup failed with exit code: $borg_exit_status" >> $log_file
fi





