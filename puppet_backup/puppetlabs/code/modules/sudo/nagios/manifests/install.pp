class nagios::install {
  package {['autoconf','gcc','libc6', 'make', 'wget', 'unzip', 'apache2', 'php', 'libapache2-mod-php7.2', 'libgd-dev', 'apache2-utils', 'nagios3-common', 'nagios3-core']:
    ensure => present,
  }

  package { "nagios3" :
    ensure  => present,
    require => [Group["nagios"], Package["apache2"]],
  }

  user { "nagios":
    ensure  => present,
    comment => "Nagios user",
    gid     => "nagios",
    shell   => "/bin/false",
    require => Group["nagios"],
  }

  group { "nagios" :
    ensure => present,
  }
}

