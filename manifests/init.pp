#
# == Class: network
#
# Manages a host's network configuration.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-network Puppet module.
# Copyright 2010-2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class network (
        Variant[Boolean, Enum['running', 'stopped']]
                                    $ensure,
        Boolean                     $enable,
        Array[String[1]]            $legacy_packages,
        String[1]                   $legacy_service,
        String[1]                   $legacy_service_provider,
        Array[String[1]]            $manager_packages,
        String[1]                   $manager_service,
        Enum['legacy', 'nm']        $service,
        String[1]                   $domain,
        Optional[Array[String[1]]]  $name_servers=undef,
        Hash[String[1], Hash]       $interfaces,
    ) {

    $ensure_legacy_service = $service ? {
        'legacy' => $ensure,
        default  => 'stopped',
    }

    $enable_legacy_service = $service ? {
        'legacy' => $enable,
        default  => false,
    }

    $ensure_nm_service = $service ? {
        'nm'    => $ensure,
        default => 'stopped',
    }

    $enable_nm_service = $service ? {
        'nm'    => $enable,
        default => false,
    }

    # PITA reduction
    file { '/etc/network':
        ensure => link,
        target => 'sysconfig/network-scripts/',
    }

    case $service {
        'legacy': {
            package { $legacy_packages:
                ensure => installed,
                notify => Service[$legacy_service],
            }
        }
        default: {
            package { $manager_packages:
                ensure => installed,
                notify => Service[$manager_service],
            }
        }
    }

    if $name_servers != undef {
        file { '/etc/resolv.conf':
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            seluser => 'system_u',
            selrole => 'object_r',
            seltype => 'net_conf_t',
            content => template('network/resolv.conf'),
        }
    }

    create_resources(::network::interface, $interfaces)

    service {
        $legacy_service:
            ensure     => $ensure_legacy_service,
            enable     => $enable_legacy_service,
            provider   => $legacy_service_provider,
            hasrestart => true,
            hasstatus  => true;

        $manager_service:
            ensure     => $ensure_nm_service,
            enable     => $enable_nm_service,
            hasrestart => true,
            hasstatus  => true;
    }

}
