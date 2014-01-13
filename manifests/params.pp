# modules/network/manifests/params.pp
#
# == Class: network::params
#
# Parameters for the network puppet module.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>


class network::params {

    case $::operatingsystem {

        Fedora: {
            $legacy_packages = [
                'initscripts',
            ]
            $manager_packages = [
                'NetworkManager',
            ]
            if $::operatingsystemrelease >= 20 {
                $gui_packages = [
                    'kde-plasma-nm',
                ]
            } else {
                $gui_packages = [
                    'kde-plasma-networkmanagement',
                ]
            }
            $manager_services = [
                'NetworkManager',
            ]

            # Starting with Fedora 19, it's necessary to force the use of the
            # systemd provider since the legacy redhat provider (which puppet
            # seems to prefer) tends to misreport the current status.
            # Furthermore, when referencing the classic network service with
            # systemd (at least for enabling), it's necessary to use the
            # '.service' suffix.
            if $::operatingsystemrelease >= 19 {
                $legacy_service_provider = 'systemd'
                $legacy_services = [
                    'network.service',
                ]
            } else {
                $legacy_service_provider = 'redhat'
                $legacy_services = [
                    'network',
                ]
            }

        }

        default: {
            fail ("The network module is not yet supported on $::operatingsystem.")
        }

    }

}
