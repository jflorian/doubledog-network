# modules/network/manifests/init.pp
#
# == Class: network
#
# Configures network services on a host.
#
# === Parameters
#
# [*service*]
#   Use 'legacy' (default) or 'nm' (NetworkManager) service.
#
# [*gui_tools*]
#   Are GUI tools to be installed?  true or false (default).
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>


class network ($service='legacy', $gui_tools=false) {

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
