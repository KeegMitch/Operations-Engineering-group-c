class nagios::config {

# File resource that manages the nagios config file
  file { "/etc/nagios3/nagios.cfg":
    ensure  => present,
    source  => "puppet:///modules/nagios/nagios.cfg",
    mode    => "0644",
    require => Class["nagios::install"],
    notify  => Class["nagios::service"],
  }

# File resource to manage usernames and passwords (causing problems)

#exec { "create-htpasswd":
 #   command => "/usr/bin/htpasswd  -c /etc/puppetlabs/code/modules/nagios/files/htpasswd.users nagiosadmin",
 #   creates => "/etc/puppetlabs/code/modules/nagios/files/htpasswd.users",
 #   require => Class["nagios::install"],
 #   notify  => Class["nagios::service"],
 #   path    => '/bin:/sbin:/usr/bin:/usr/sbin',

#  }

  file { "/etc/nagios3/htpasswd.users":
    ensure  => present,
    source  => "puppet:///modules/nagios/htpasswd.users",
    mode    => "0600",
    owner   => "nagios",
    group   => "nagios",
#    require => Exec["create-htpasswd"],
    notify  => Class["nagios::service"],
  }

# File resource that ensures the /etc/nagios3/conf.d directory is present, sets its group ownership to puppet, and its mode to 0775

file { "/etc/nagios3/conf.d":
    ensure  => directory,
    mode    => "0775",
    owner   => "root",
    group   => "puppet",
    require => Class["nagios::install"],
  }
}

# Define the nagios_host resource to monitor the status of the database server

 #define nagios_host (
 #   $target,
 #   $alias,
 #   $check_period,
 #   $max_check_attempts,
 #   $check_command,
 #   $notification_interval,
 #   $notification_period,
 #   $notification_options,
#    $mode,
#    $prefix = "ppt_"
#  ) {
#    file { "/etc/nagios3/conf.d/${prefix}hosts.cfg":
#      ensure  => present,
#      content => "
#define host {
#  host_name               ${title}
#  alias              ${alias}
#  address                 ${target}
#  check_period            ${check_period}
#  max_check_attempts      ${max_check_attempts}
#  check_command           ${check_command}
#  notification_interval   ${notification_interval}
#  notification_period     ${notification_period}
#  notification_options    ${notification_options}
#}
#",
#      mode    => $mode,
#      require => File['/etc/nagios3/conf.d'],
#    }
#  }

  # Use the custom nagios_host resource type to define the Nagios host
#  nagios::config::nagios_host { "db-c.foo.org.nz":
#    target                => "db-c.foo.org.nz",
#    alias            => "db",
#    check_period          => "24x7",
#    max_check_attempts    => 3,
#    check_command         => "check-host-alive",
#    notification_interval => 30,
#    notification_period   => "24x7",
#    notification_options  => "d,u,r",
#    mode                  => "0444",
 # }

#}

