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

            # NB: This condition is not based on when 'systemd' was
            # introduced, but what Fedora releases are known to be flakey when
            # using the legacy 'redhat' provider that puppet seems to sadly
            # prefer.  The threshold may require adjustment over time, but
            # thus far Fedora 20 is known to require systemd here.
            if $::operatingsystemrelease >= 20 {
                $legacy_service_provider = 'systemd'
            } else {
                $legacy_service_provider = 'redhat'
            }

        }

        default: {
            fail ("The network module is not yet supported on $::operatingsystem.")
        }

    }

}
