#!/bin/bash

# Config for our app server to backup


sudo tar -czvf backup_directories.tar.gz App_backup database_backup mgmt_backups nagiosbackup rsync_backup
