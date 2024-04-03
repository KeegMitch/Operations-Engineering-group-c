class ntp_service {
  class { 'ntp_service::install': }
  class { 'ntp_service::config': }
  class { 'ntp_service::service': }
  class { 'ntp_service::notify': }
}


class ntp_service::install {
  package { 'ntp':
    ensure => present,
  }
}

class ntp_service::config {
  if $hostname == 'mgmt-c' {
    $restrict = "restrict 10.25.0.0 mask 255.255.0.0 nomodify notrap"
    $server = "server 127.127.1.0"
    $fudge = "127.127.1.0 stratum 10"
  } else {
    $restrict = ''
    $server = "server mgmt-c.foo.org.nz prefer"
    $fudge = ''
  }

  file { '/etc/ntp.conf':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0444',
    content => template("ntp_service/ntp.conf.erb"),
  }
}

class ntp_service::service {
  service { 'ntp':
    ensure => running,
    enable => true,
  }
}

class ntp_service::notify {
  exec { 'check_ntp_status':
    command     => '/bin/systemctl is-active ntp',
    refreshonly => true,
    logoutput   => true,
    notify      => Notify['ntp_status'],
  }

  exec { 'notify_ntp_status':
    command     => '/bin/systemctl is-active ntp',
    refreshonly => true,
    logoutput   => true,
    subscribe   => Exec['check_ntp_status'],
    notify      => Notify['ntp_status'],
  }

  notify { 'ntp_status':
    message  => 'NTP service is running',
    withpath => false,
    subscribe => Exec['notify_ntp_status'],
  }
}

