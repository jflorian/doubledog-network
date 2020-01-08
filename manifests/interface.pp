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
# Copyright 2010-2020 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


define network::interface (
        Network::Template               $template,
        Ddolib::File::Ensure::Limited   $ensure='present',
        Optional[String[1]]             $bridge=undef,
        String[2,2]                     $country='US',
        Optional[String[1]]             $essid=undef,
        Optional[String[1]]             $eth_offload=undef,
        Optional[String[1]]             $gateway=undef,
        Optional[String[1]]             $ip_address=undef,
        Enum['WPA-PSK']                 $key_mgmt='WPA-PSK',
        Optional[String[1]]             $mac_address=undef,
        Enum['Managed']                 $mode='Managed',
        Optional[String[1]]             $netmask=undef,
        Boolean                         $peer_dns=true,
        Boolean                         $peer_ntp=true,
        Boolean                         $persistent_dhcp=true,
        Optional[String[1]]             $psk=undef,
        Optional[Hash[String[1], Hash]] $routes=undef,
        Boolean                         $stp=true,
        Optional[Network::Vlan_id]      $vlan=undef,
    ) {

    # Sterilize the name.
    $sterile_name = regsubst($name, '[^\w.]+', '_', 'G')

    # The template needs a particular macaddress fact, but it cannot do
    # something like "<%= @macaddress_<%= name %>%>", so this little trick is
    # used here to accomplish the variable interpolation.
    $mac_fact = "macaddress_${name}"
    $interface_hwaddr = inline_template('<%= scope.lookupvar(@mac_fact) %>')

    $subscribers = $network::service ? {
        'legacy' => Service[$network::legacy_service],
        default  => [
            Exec["reconnect ${sterile_name}"],
            Exec["reload ${sterile_name}"],
            Exec["disconnect ${sterile_name}"],
        ]
    }

    $routes_ensure = $routes ? {
        undef   => 'absent',
        default => 'present'
    }

    $routes_content = $routes ? {
        undef   => undef,
        default => template("network/route.erb")
    }

    file {
        default:
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            seluser => 'system_u',
            selrole => 'object_r',
            seltype => 'net_conf_t',
            notify  => $subscribers,
            ;
        "/etc/sysconfig/network-scripts/ifcfg-${sterile_name}":
            ensure  => $ensure,
            content => template("network/ifcfg-${template}.erb"),
            ;
        "/etc/sysconfig/network-scripts/route-${sterile_name}":
            ensure  => $routes_ensure,
            content => $routes_content,
            ;
    }

    if $template == 'wireless' {
        include 'network::wireless'
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
        # React to realize changes immediately.
        exec {
            default:
                path        => '/usr/bin:/bin:/usr/sbin:/sbin',
                refreshonly => true,
                ;
            "reload ${sterile_name}":
                command => "nmcli connection reload ${sterile_name}",
                before  => Exec["disconnect ${sterile_name}"],
                ;
            # This is brutish, but the only means I could find to affect the
            # runtime state to fully match the configured state.
            "disconnect ${sterile_name}":
                command => "nmcli device disconnect ${sterile_name}",
                before  => Exec["reconnect ${sterile_name}"],
                ;
            "reconnect ${sterile_name}":
                command => "nmcli device connect ${sterile_name}",
                ;
        }
    }

}
