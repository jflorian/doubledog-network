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
# [*enable*]
#   Selected service is to be started at boot.  Either true (default) or
#   false.
#
# [*ensure*]
#   Selected service is to be 'running' (default) or 'stopped'.
#   Alternatively, a Boolean value may also be used with true equivalent to
#   'running' and false equivalent to 'stopped'.
#
# [*legacy_packages*]
#   An array of package names needed for a legacy network installation.
#
# [legacy_service*]
#   The name of the legacy network service.
#
# [legacy_service_provider*]
#   The name of the Puppet provider to manage the legacy network service.
#
# [*manager_packages*]
#   An array of package names needed for a NetworkManager installation.
#
# [manager_service*]
#   The name of the NetworkManager service.
#
# [*service*]
#   Use 'legacy' (default) or 'nm' (NetworkManager) service.
#
# [*domain*]
#   Name of the network domain.  Typically not required for hosts with
#   interfaces configured exclusively by DHCP.
#   fact.
#
# [*interfaces*]
#   A hash whose keys are interface names and whose values are hashes
#   comprising the same parameters you would otherwise pass to
#   Define[network::interface].
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
# Copyright 2010-2017 John Florian


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
