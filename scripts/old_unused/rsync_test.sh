#!/bin/bash

# From Digital ocean Rsync tutorial

# make some test directories
cd ~
sudo mkdir dir1
sudo touch dir1/file{1..100}
ls dir1

# rsync directory with -a flag meaning it syncs recursively and preserves symbolic links, 
# special and device files, modification times, groups, owners, and permissions

sudo rsync -a dir1/ dir2

# sync with backup server first

sudo rsync -a ~/dir1 group-c@backup-c:~


# sudo rsync -a --delete --backup --backup-dir=/home/group-c/backups /home/group-c/dir1 group-c@backup-c:/home/group-c/dir1

# sudo crontab: cron job for 4 times a day: 0 0,6,12,18 * * * /home/group-c/rsync_test.sh
