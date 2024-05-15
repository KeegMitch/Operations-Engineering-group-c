#!/bin/bash

# Define source directories
puppet_dir="/etc/puppetlabs/"

current_date=$(date +"%B_%d_%Y_%H%M%S")

# Define archive filename
archive_name="RsyncPuppetbackup_$current_date.tar.gz"

sudo rsync -av --link-dest=/home/group-c/rsync_backup -e "ssh -i /home/group-c/.ssh/id_rsa" /etc/puppetlabs group-c@backup-c:~/rsync_backup

# rsync to storage server

if [[ $? -eq 0 ]]; then
echo "Backup created: $archive_name"

fi
