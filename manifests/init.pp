# modules/network/manifests/init.pp
#
# Synopsis:
#       Configures network services on a host.
#
# Parameters:
#       Name__________  Default_______  Description___________________________
#
#       network_manager false           Install NetworkManager and related
#                                       packages, which are useful on WiFi
#                                       capable devices.
#
# Requires:
#       NONE
#
# Example Usage:
#
#       class {'network':
#            network_manager => true,
#       }

class network ($network_manager=false) {

    package { 'initscripts':
        ensure  => installed,
    }

    if $network_manager == true {
        package { ['NetworkManager', 'kde-plasma-networkmanagement']:
            ensure => installed,
        }
    } else {
        yum::remove { 'NetworkManager':
            before  => Service['network'],
            # It may be necessary to have the replacement installed prior to
            # removal of the conflicting package.
            require => Package['initscripts'],
        }
    }

    # PITA reduction
    file { "/etc/network":
        ensure  => link,
        target  => "sysconfig/network-scripts/",
    }

    service { 'network':
        enable          => true,
        ensure          => running,
        hasrestart      => true,
        hasstatus       => true,
        require         => [
            Package['initscripts'],
        ],
    }

}
