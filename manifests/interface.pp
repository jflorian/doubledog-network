#
# == Define: network::interface
#
# Manages a network interface configuration.
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


define network::interface (
        Enum['dhcp', 'dhcp-bridge', 'static', 'static-bridge', 'wireless']
                                    $template,
        Enum['present', 'absent']   $ensure='present',
        Optional[String[1]]         $bridge=undef,
        String[2,2]                 $country='US',
        Optional[String[1]]         $eth_offload=undef,
        Optional[String[1]]         $gateway=undef,
        Optional[String[1]]         $ip_address=undef,
        Enum['WPA-PSK']             $key_mgmt='WPA-PSK',
        Optional[String[1]]         $mac_address=undef,
        Enum['Managed']             $mode='Managed',
        Optional[String[1]]         $netmask=undef,
        Boolean                     $peer_dns=true,
        Boolean                     $peer_ntp=true,
        Boolean                     $persistent_dhcp=true,
        Optional[String[1]]         $psk=undef,
        Boolean                     $stp=true,
        # $vlan as String is a kludge for Hiera interpolation forcing values
        # to String.
        Optional[Variant[Integer[1, 4094], String[1]]]
                                    $vlan=undef,
    ) {

    # Sterilize the name.
    $sterile_name = regsubst($name, '[^\w.]+', '_', 'G')

    # The template needs a particular macaddress fact, but it cannot do
    # something like "<%= @macaddress_<%= name %>%>", so this little trick is
    # used here to accomplish the variable interpolation.
    $mac_fact = "macaddress_${name}"
    $interface_hwaddr = inline_template('<%= scope.lookupvar(@mac_fact) %>')

    $notify_service = $network::service ? {
        'legacy' => Service[$network::legacy_service],
        default  => Service[$network::manager_service],
    }

    file { "/etc/sysconfig/network-scripts/ifcfg-${sterile_name}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'net_conf_t',
        content => template("network/ifcfg-${template}.erb"),
        notify  => $notify_service,
    }

    if $template == 'wireless' {
        include '::network::wireless'
        if $key_mgmt == 'WPA-PSK' {
            file { "/etc/sysconfig/network-scripts/keys-${sterile_name}":
                ensure    => $ensure,
                owner     => 'root',
                group     => 'root',
                mode      => '0600',
                seluser   => 'system_u',
                selrole   => 'object_r',
                seltype   => 'net_conf_t',
                content   => "WPA_PSK='${psk}'\n",
                show_diff => false,
            }
        }
    }

    if $network::service == 'nm' {
        # Use a dispatch script that NetworkManager can call to effect any TCP
        # offload configuration.
        $script = "/etc/NetworkManager/dispatcher.d/00-config-${sterile_name}"
        if $eth_offload {
            file { $script:
                ensure  => $ensure,
                owner   => 'root',
                group   => 'root',
                mode    => '0755',
                seluser => 'system_u',
                selrole => 'object_r',
                seltype => 'NetworkManager_initrc_exec_t',
                content => template('network/dispatcher.sh.erb'),
            }
        } else {
            file { $script:
                ensure  => absent,
            }
        }
    }

}
