#!/bin/bash

# Backup our backup servers to put into storage server

#!/bin/bash

# Define variables
SOURCE_ITEMS=(
    "App_backup"
    "database_backup"
    "mgmt_backups"
    "nagiosbackup"
    "rsync_backup"
    "node_exporter-1.0.0-rc.0.linux-amd64"
    "node_exporter-1.0.0-rc.0.linux-amd64.tar.gz"
    "prometheus-2.18.0-rc.1.linux-amd64"
    "prometheus-2.18.0-rc.1.linux-amd64.tar.gz"
    "puppet6-release-bionic.deb"

)

current_date=$(date +"%B_%d_%Y_%H%M%S")
REMOTE_USER="group-c"
REMOTE_SERVER="20.211.153.89" # public ip of storage server
REMOTE_DIR="/home/$remote_user/backup-c"
BACKUP_FILE="backup_directories_$current_date.tar.gz"

# Log function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Start logging
log "Backup process started."


# Change ownership and permissions
log "Changing ownership and permissions..."
for item in "${SOURCE_ITEMS[@]}"; do
    if sudo chown -R group-c:group-c "$item" && sudo chmod -R 700 "$item"; then
        log "Changed ownership and permissions for $item."
    else
        log "Error changing ownership or permissions for $item."
        exit 1
    fi
done

# Create a tarball of the directories
log "Creating a compressed archive of the directories..."
if tar -czvf $BACKUP_FILE "${SOURCE_ITEMS[@]}"; then
    log "Created tarball $BACKUP_FILE successfully."
else
    log "Error creating tarball $BACKUP_FILE."
    exit 1
fi

# Transfer the tarball to the remote server (commented out until storage server works)
# log "Transferring the backup to the remote server..."
# if rsync -avz -e "ssh -i /home/group-c/.ssh/id_rsa_backup_storage" $BACKUP_FILE $REMOTE_USER@$REMOTE_SERVER:$REMOTE_DIR; then
#    log "Transferred $BACKUP_FILE to $REMOTE_SERVER successfully."
#else
#    log "Error transferring $BACKUP_FILE to $REMOTE_SERVER."
#    exit 1
#fi

# Cleanup: Optionally remove the local tarball after transfer
# Uncomment the following lines if you want to remove the local backup file after transfer
# log "Cleaning up local backup file..."
# if rm $BACKUP_FILE; then
#     log "Local backup file $BACKUP_FILE removed successfully."
# else
#     log "Error removing local backup file $BACKUP_FILE."
#     exit 1
# fi

echo "Backup process completed successfully."
