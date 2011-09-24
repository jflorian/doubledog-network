# /etc/puppet/modules/network/manifests/init.pp

class network {

    include common

    # Determine which network service to be used.  Droopy requires network
    # service for bridging.  Pluto is also special with pyptables.
    if ($operatingsystemrelease >= 15 and $hostname != 'droopy-f15' and
        $hostname != 'pluto-f15') {

        $network_package = "NetworkManager"
        $network_service = "NetworkManager"

        service { "network":
            enable      => false,
            ensure      => stopped,
            hasrestart  => true,
            hasstatus   => false,
            status      => "ip link show dev ${interface} | grep -q ',UP,'",
        }

    } else {

        $network_package = "initscripts"
        $network_service = "network"

        package { "NetworkManager":
            ensure  => absent,
        }

    }

    # Determine interface name.
    $interface = $hostname ? {
        "droopy-f15"    => "br0",
        "zuul"          => "p32p1",
        default         => "eth0",
    }

    package { "$network_package":
        ensure  => installed,
    }

    # Set up a link of /etc/network to /etc/sysconfig/network-scripts/ because
    # the latter is such a stupid PITA.
    file { "/etc/network":
        ensure  => "sysconfig/network-scripts/",
    }

    # Configure the DHCP client to not manage NTP settings.  We want DHCP to
    # configure NTP right up until we begin having puppet manage a host.
    line { "disable PEERNTP":
        ensure  => present,
        file    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
        line    => "PEERNTP=no",
        notify  => Service["$network_service"],
    }

    service { "$network_service":
        enable          => true,
        ensure          => running,
        hasrestart      => true,
        hasstatus       => false,
        require         => Package["$network_package"],
        status          => "ip link show dev ${interface} | grep -q ',UP,'",
    }

}
