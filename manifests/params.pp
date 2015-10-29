# modules/network/manifests/params.pp
#
# == Class: network::params
#
# Parameters for the network puppet module.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2010-2015 John Florian


class network::params {

    case $::operatingsystem {

        'CentOS', 'Fedora': {

            $legacy_packages = 'initscripts'
            $legacy_service_provider = 'systemd'
            $legacy_services = 'network.service'
            $manager_packages = 'NetworkManager'
            $manager_services = 'NetworkManager'

        }

        default: {
            fail ("${title}: operating system '${::operatingsystem}' is not supported")
        }

    }

}
