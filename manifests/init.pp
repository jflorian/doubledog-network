# modules/network/manifests/init.pp
#
# == Class: network
#
# Configures network services on a host.
#
# === Parameters
#
# [*service*]
#   Use 'legacy' (default) or 'nm' (NetworkManager) service.  Required.
#
# [*domain*]
#   Name of the network domain.  Optional.  Typically not required for hosts
#   with interfaces configured exclusively by DHCP.
#
# [*name_servers*]
#   List of IP addresses that provide DNS name resolution.  Optional.
#   Typically not required for hosts with interfaces configured exclusively by
#   DHCP.  If set, this will cause the name resolver configuration to be
#   managed.
#
# [*gui_tools*]
#   Are GUI tools to be installed?  true or false (default).
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>


class network ($service='legacy', $domain=undef, $name_servers=undef,
               $gui_tools=false) {

    include 'network::params'

    # PITA reduction
    file { "/etc/network":
        ensure  => link,
        target  => "sysconfig/network-scripts/",
    }

    package {

        $network::params::legacy_packages:
            ensure  => installed,
            notify  => Service[$network::params::legacy_services];

        $network::params::manager_packages:
            ensure  => installed,
            notify  => Service[$network::params::manager_services];

        $network::params::gui_packages:
            ensure  => $gui_tools ? {
                true    => installed,
                default => absent,
            };

    }

    if $name_servers != undef {
        file { '/etc/resolv.conf':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            seluser => 'system_u',
            selrole => 'object_r',
            seltype => 'etc_t',
            content => template('network/resolv.conf'),
        }
    }

    service {

        $network::params::legacy_services:
            enable      => $service ? {
                'legacy'    => true,
                default     => false,
            },
            ensure      => $service ? {
                'legacy'    => running,
                default     => stopped,
            },
            provider    => $network::params::legacy_service_provider,
            hasrestart  => true,
            hasstatus   => true;

        $network::params::manager_services:
            enable      => $service ? {
                'nm'        => true,
                default     => false,
            },
            ensure      => $service ? {
                'nm'        => running,
                default     => stopped,
            },
            hasrestart  => true,
            hasstatus   => true;

    }

}
