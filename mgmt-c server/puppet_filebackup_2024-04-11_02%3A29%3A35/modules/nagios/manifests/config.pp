class nagios::config {

# File resource that manages the nagios config file
  file { "/etc/nagios3/nagios.cfg":
    ensure  => present,
    source  => "puppet:///modules/nagios/nagios.cfg",
    mode    => "0644",
    owner =>  "root",
    group =>  "root",
    require => Class["nagios::install"],
    notify  => Class["nagios::service"],
  }

# Manually create the htpasswds file
# File resource to manage usernames and passwords
  file { "/etc/nagios3/htpasswd.users":
    ensure  => present,
    source  => "puppet:///modules/nagios/htpasswd.users",
    mode    => "0644",
    owner   => "root",
    group   => "root",
    require => Class["nagios::install"],
    notify  => Class["nagios::service"],
  }

# File resource that ensures the /etc/nagios3/conf.d directory is present, sets its group ownership to puppet, and its mode to 0775

file { "/etc/nagios3/conf.d":
    ensure  => directory,
    mode    => "0775",
    owner   => "root",
    group   => "puppet",
    require => Class["nagios::install"],
    notify => Class["nagios::service"],
  }


# Define the nagios_host resource to monitor the status of the database server
# In order for all this code to work though, manually download the puppetlabs/nagios_core module first
nagios_host { "db-c":
    target                => "/etc/nagios3/conf.d/ppt_hosts.cfg",
    alias                 => "db",
    check_period          => "24x7",
    max_check_attempts    => 3,
    check_command         => "check-host-alive",
    notification_interval => 30,
    notification_period   => "24x7",
    notification_options  => "d,u,r",
    mode                  => "0444",
 }



nagios_host { "app-c":
    target                => "/etc/nagios3/conf.d/ppt_hosts.cfg",
    alias                 => "app",
    check_period          => "24x7",
    max_check_attempts    => 3,
    check_command         => "check-host-alive",
    notification_interval => 30,
    notification_period   => "24x7",
    notification_options  => "d,u,r",
    mode                  => "0444",
 }



nagios_host { "backup-c":
    target                => "/etc/nagios3/conf.d/ppt_hosts.cfg",
    alias                 => "backup",
    check_period          => "24x7",
    max_check_attempts    => 3,
    check_command         => "check-host-alive",
    notification_interval => 30,
    notification_period   => "24x7",
    notification_options  => "d,u,r",
    mode                  => "0444",
 }



nagios_host { "mgmt-c":
    target                => "/etc/nagios3/conf.d/ppt_hosts.cfg",
    alias                 => "mgmt",
    check_period          => "24x7",
    max_check_attempts    => 3,
    check_command         => "check-host-alive",
    notification_interval => 30,
    notification_period   => "24x7",
    notification_options  => "d,u,r",
    mode                  => "0444",
 }

# nagios hostgroups

nagios_hostgroup {"my-ssh-servers":
   target => "/etc/nagios3/conf.d/ppt_hostgroups.cfg",
   mode => "0444",
   alias => "My SSH servers",
   members => "db-c, app-c, backup-c, mgmt-c",
}

nagios_hostgroup {"my-mariaDB-servers":
  target => "/etc/nagios3/conf.d/ppt_hostgroups.cfg",
  mode => "0444",
  alias => "My mariaDB servers",
  members => "db-c",
}

# new hostgroup for remote disks (edit to add all servers)


nagios_hostgroup {"Remote-Disks":
  target => "/etc/nagios3/conf.d/ppt_hostgroups.cfg",
  mode => "0444",
  alias => "Remote Disks",
  members => "db-c, app-c, backup-c, mgmt-c",
}

# nagios services

nagios_service {"ssh":
service_description => "ssh servers",
hostgroup_name => "my-ssh-servers",
target => "/etc/nagios3/conf.d/ppt_services.cfg",
check_command => "check_ssh",
max_check_attempts => 3,
retry_check_interval => 1,
normal_check_interval => 5,
check_period => "24x7",
notification_interval => 30,
notification_period => "24x7",
notification_options => "w,u,c",
contact_groups => "admins",
mode => "0444",
}

nagios_service {"mariaDB":
service_description => "mariaDB servers",
hostgroup_name => "my-mariaDB-servers",
target => "/etc/nagios3/conf.d/ppt_services.cfg",
check_command => "check_mysql_cmdlinecred!nagios!mypasswd",
max_check_attempts => 3,
retry_check_interval => 1,
normal_check_interval => 5,
check_period => "24x7",
notification_interval => 30,
notification_period => "24x7",
notification_options => "w,u,c",
contact_groups => "admins",
mode => "0444",
}

# Adding new service for disk check via NRPE

nagios_service {"root_disk_check":
  service_description => "Root Disk Space",
  hostgroup_name => "Remote-Disks",
  target => "/etc/nagios3/conf.d/ppt_services.cfg",
  check_command => "check_nrpe!check_sda1",
  max_check_attempts => 3,
  retry_check_interval => 1,
  normal_check_interval => 5,
  check_period => "24x7",
  notification_interval => 30,
  notification_period => "24x7",
  notification_options => "w,u,c",
  contact_groups => "admins",
  mode => "0444",
}

# Slack notification for nagios
nagios_contact { "slack":
target => "/etc/nagios3/conf.d/ppt_contacts.cfg",
alias => "Slack",
service_notification_period => "24x7",
host_notification_period => "24x7",
service_notification_options => "w,u,c,r",
host_notification_options => "d,r",
service_notification_commands => "notify-service-by-slack",
host_notification_commands => "notify-host-by-slack",
email => "root@localhost",
mode => "0444",
}

nagios_contactgroup { "slackgroup":
target => "/etc/nagios3/conf.d/ppt_contactgroups.cfg",
alias => "Slack channel",
members => "slack",
mode => "0444",
}

}

