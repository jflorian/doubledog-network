# modules/network/manifests/classes/network.pp
#
# Synopsis:
#       Configures network services on a host.
#
# Parameters:
#       Name__________  Default_______  Description___________________________
#       NONE
#
# Requires:
#       NONE
#
# Example usage:
#
#       include network

class network {

    package { 'initscripts':
        ensure  => installed,
    }

    yum::remove { 'NetworkManager':
        before  => Service['network'],
        # It may be necessary to have the replacement installed prior to
        # removal of the conflicting package.
        require => Package['initscripts'],
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
