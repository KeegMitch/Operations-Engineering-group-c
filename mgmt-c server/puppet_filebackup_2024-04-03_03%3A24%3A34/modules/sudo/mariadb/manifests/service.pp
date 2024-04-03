class mariadb::service {
service { "mysql" :
ensure => running,
hasstatus => true,
hasrestart => true,
enable => true,
require => Class["mariadb::config"],
}
}
