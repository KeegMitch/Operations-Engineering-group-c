class nagios::install {
        package{ "nagios3":
        ensure=>present,
        }
        package { "apache2-utils":
                ensure => present,
        }
        user { "nagios":
        ensure => present,
        }
        group { "nagios":
        ensure => present,
        }
}

