#!/bin/bash

# Define source and destination directories
SOURCE_DIR="/home/group-c/app-c/"
DEST_DIR="group-c@app-c:~/testEtc/"

# Run rsync to transfer files from the backup server to the app server
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR"

sudo rm -r "$SOURCE_DIR"/*
