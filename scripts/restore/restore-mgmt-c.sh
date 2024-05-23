#!/bin/bash

# Define source and destination directories
SOURCE_DIR="group-c@20.211.153.89:/home/group-c/mgmt-c/"
DEST_DIR="/home/group-c/mgmt-c/"

# Define Puppet configuration directory
PUPPET_CONFIG_DIR="/etc/puppetlabs"


# Step 1: Run rsync to grab the latest backup
echo "Syncing backup from remote server..."
sudo rsync -av "$SOURCE_DIR" "$DEST_DIR"

# Step 2: Uncompress the latest backup
echo "Uncompressing the latest backup..."
cd "$DEST_DIR"
LATEST_BACKUP=$(ls -t | head -n1)
sudo tar -xzvf "$LATEST_BACKUP" -C ./

# Step 3: Install Puppet 6
install_puppet() {
  echo "Installing Puppet 6..."
  wget https://apt.puppetlabs.com/puppet6-release-$(lsb_release -cs).deb
  sudo dpkg -i puppet6-release-$(lsb_release -cs).deb
  sudo apt update
  sudo apt install -y puppetserver
}

# Step 4: Restore Puppet configuration
restore_puppet() {
  echo "Restoring Puppet configuration..."
  if [ -d "$BACKUP_DIR/$PUPPET_CONFIG_DIR" ]; then
    sudo rsync -av "$DEST_DIR/$PUPPET_CONFIG_DIR/" "$PUPPET_CONFIG_DIR/"
  else
    echo "Backup directory $DEST_DIR/$PUPPET_CONFIG_DIR does not exist."
    exit 1
  fi
  sudo systemctl start puppetserver
  sudo systemctl enable puppetserver
}

# Step 5: Connect Puppet agent to Puppet master
connect_puppet_agent() {
  echo "Connecting Puppet agent to Puppet master..."
  sudo /opt/puppetlabs/puppet/bin/puppet agent --server=mgmt-c --no-daemonize --verbose --onetime
}

# Step 6: Test Puppet agent
test_puppet_agent() {
  echo "Testing Puppet agent..."
  sudo /opt/puppetlabs/puppet/bin/puppet agent --test
  # sudo puppet agent --test
}

# Step 7: Verify services
verify_services() {
  echo "Verifying services..."
  sudo systemctl status puppetserver
  sudo systemctl status nagios
}

# Main script execution
echo "Starting restoration process..."

install_puppet
restore_puppet
apply_puppet
verify_services

echo "Restoration process completed successfully."
