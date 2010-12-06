# /etc/puppet/modules/network/manifests/init.pp

class network {

    include common

    $interface = $hostname ? {
        "droopy"        => "br0",
        default         => "eth0",
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
        notify  => Service["network"],
    }

    service { "network":
        enable		=> true,
        ensure		=> running,
        hasrestart	=> true,
        hasstatus	=> false,
        status          => "ip link show dev ${interface} | grep -q ',UP,'",
    }

}
