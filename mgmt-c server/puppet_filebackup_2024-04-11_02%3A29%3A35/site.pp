node 'db-c.foo.org.nz' {
#include sudo
#include ntp_service
#include mariadb
include nrpe
package { 'vim': ensure => present }
}

node 'mgmt-c.foo.org.nz' {
#include sudo
#include ntp_service
include nagios
package { 'vim': ensure => present }
}

node 'app-c.foo.org.nz' {
#include sudo
#include ntp_service
include nrpe
package { 'vim': ensure => present }
}

node 'backup-c.foo.org.nz' {
#include sudo
#include ntp_service
include nrpe
package { 'vim': ensure => present }
}

