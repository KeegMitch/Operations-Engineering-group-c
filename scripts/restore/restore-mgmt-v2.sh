#!/bin/bash

# Define source and destination directories
SOURCE_DIR="group-c@20.211.153.89:/home/group-c/mgmt-c/"
DEST_DIR="/home/group-c/mgmt-c/"

# Run rsync to grab the latest backup
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR"

# Uncompress the latest backup
cd "$DEST_DIR""/rsync_backup/"
sudo tar -xzvf $(ls -t | head -n1) -C ./
