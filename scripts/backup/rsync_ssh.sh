#!/bin/bash

# Define source directories
ssh_dir="/home/group-c/.ssh"
# modules_dir="/etc/puppetlabs/code/modules"
# site_pp="/etc/puppetlabs/code/environments/production/manifests/site.pp"
user="group-c"
backup_server="backup-c"
storage_server="20.211.153.89"


# Get the current date and time
current_date=$(date +"%B_%d_%Y_%H%M%S")

# create backup
log_dir="$HOME/logs"
log_file="$log_dir/rsync_sshconf.log"

if [ ! -d "$log_dir" ]; then
   sudo mkdir -p "$log_dir"
fi

# Define archive filename
archive_name="sshbackup_$current_date.tar.gz"

# Create the puppet_backups directory if it doesn't exist
backup_dir="$HOME/ssh_backups"

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
# sudo tar -czvf "$HOME/mgmt_backups/$archive_name" "$modules_dir" "$site_pp"
sudo tar -czvf "$backup_dir/$archive_name" "$ssh_dir" >> $log_file

# rsync into storage server (why is it not working?)

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
