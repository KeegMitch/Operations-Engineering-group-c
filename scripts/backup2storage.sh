#!/bin/bash

# Backup home directory to storage server

# Define variables
HOME_DIR="/home/group-c"
LOG_FILE="$HOME_DIR/backup_log_$(date +'%Y-%m-%d').log"
REMOTE_USER="group-c"
REMOTE_SERVER="20.211.153.89" # public IP of storage server
REMOTE_DIR="/home/$REMOTE_USER/backup-c"
current_date=$(date +"%B_%d_%Y_%H%M%S")
BACKUP_FILE="backup_server_${current_date}.tar.gz"

# Log function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Start logging
log "Backup process started."

# Change ownership and permissions of the home directory
log "Changing ownership and permissions of the home directory..."
if sudo chown -R group-c:group-c "$HOME_DIR" && sudo chmod -R 700 "$HOME_DIR"; then
    log "Changed ownership and permissions for $HOME_DIR."
else
    log "Error changing ownership or permissions for $HOME_DIR."
    exit 1
fi

# Create a tarball of the home directory (excluding hidden files)
log "Creating a compressed archive of the home directory (excluding hidden files)..."
if tar -czvf $BACKUP_FILE --exclude=".*" -C $HOME_DIR .; then
    log "Created tarball $BACKUP_FILE successfully."
else
    log "Error creating tarball $BACKUP_FILE."
    exit 1
fi

# Transfer the tarball to the remote server
log "Transferring the backup to the remote server..."
if rsync -av -e "ssh -i /home/group-c/.ssh/id_rsa_backup_storage" $BACKUP_FILE $REMOTE_USER@$REMOTE_SERVER:$REMOTE_DIR; then
    log "Transferred $BACKUP_FILE to $REMOTE_SERVER successfully."
else
    log "Error transferring $BACKUP_FILE to $REMOTE_SERVER."
    exit 1
fi

# Cleanup: Optionally remove the local tarball after transfer
# Uncomment the following lines if you want to remove the local backup file after transfer
# log "Cleaning up local backup file..."
# if rm $BACKUP_FILE; then
#     log "Local backup file $BACKUP_FILE removed successfully."
# else
#     log "Error removing local backup file $BACKUP_FILE."
#     exit 1
# fi

log "Backup process completed successfully."
