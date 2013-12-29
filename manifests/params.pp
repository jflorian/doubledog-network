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
            $gui_packages = [
                'kde-plasma-networkmanagement',
            ]
            $legacy_services = [
                'network',
            ]
            $manager_services = [
                'NetworkManager',
            ]

        }

        default: {
            fail ("The network module is not yet supported on $::operatingsystem.")
        }

    }

}
