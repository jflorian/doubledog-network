# modules/network/manifests/init.pp
#
# == Class: network
#
# Manages a host's network configuration.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# [*service*]
#   Use 'legacy' (default) or 'nm' (NetworkManager) service.
#
# [*domain*]
#   Name of the network domain.  Typically not required for hosts with
#   interfaces configured exclusively by DHCP.  Defaults to the $::domain
#   fact.
#
# [*name_servers*]
#   Array of IP address strings that provide DNS address resolution.
#   Typically not required for hosts with interfaces configured exclusively by
#   DHCP.  If set, this will cause the name resolver configuration to be
#   managed.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2010-2016 John Florian


class network (
        $service='legacy',
        $domain=$::domain,
        $name_servers=undef,
    ) inherits ::network::params {

    validate_re(
        $service, '^(legacy|nm)$',
        "${title}: 'service' must be one of: 'legacy' or 'nm'"
    )

    $ensure_legacy_service = $service ? {
        'legacy' => 'running',
        default  => 'stopped',
    }

    $enable_legacy_service = $service ? {
        'legacy' => true,
        default  => false,
    }

    $ensure_nm_service = $service ? {
        'nm'    => 'running',
        default => 'stopped',
    }

    $enable_nm_service = $service ? {
        'nm'    => true,
        default => false,
    }

    # PITA reduction
    file { '/etc/network':
        ensure => link,
        target => 'sysconfig/network-scripts/',
    }

    package {
        $::network::params::legacy_packages:
            ensure => installed,
            notify => Service[$::network::params::legacy_services];

        $::network::params::manager_packages:
            ensure => installed,
            notify => Service[$::network::params::manager_services];
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

    service {
        $::network::params::legacy_services:
            ensure     => $ensure_legacy_service,
            enable     => $enable_legacy_service,
            provider   => $::network::params::legacy_service_provider,
            hasrestart => true,
            hasstatus  => true;

        $::network::params::manager_services:
            ensure     => $ensure_nm_service,
            enable     => $enable_nm_service,
            hasrestart => true,
            hasstatus  => true;
    }

}
