# modules/network/manifests/interface.pp
#
# == Define: network::interface
#
# Manages a network interface configuration.
#
# === Parameters
#
# ==== Required
#
# [*namevar*]
#   Name of the interface, e.g., 'eth0'.  If template is 'wireless' this must
#   be set to the Extended Service Set Identification (ESSID) of the wireless
#   network.
#
# [*template*]
#   The particular template to be used.  Must be one of 'dhcp', 'dhcp-bridge',
#   'static', 'static-bridge' or 'wireless'.  The 'wireless' template assumes
#   a DHCP configuration and is only supported when $network::service is 'nm'
#   (NetworkManager).
#
# ==== Optional
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*eth_offload*]
#   Any device-specific options supported by ethtool's -K option expressed as
#   a simple string passed along unmodified.  E.g., "gso off".
#
# [*bridge*]
#   Name of the associated bridge interface, if any.  Ignored for the bridge
#   and wireless templates.
#
# [*gateway*]
#   The default route address to be assigned to the interface.  Recommended
#   for the static templates and ignored for the dhcp and wireless templates.
#
# [*ip_address*]
#   The address to be assigned to the interface.  Required for the static
#   templates and ignored for the dhcp and wireless templates.
#
# [*key_mgmt*]
#   Key management for wireless encryption.  Must be one of 'WPA-PSK'
#   (default) or ???.  Ignored for all but the wireless template.
#
# [*mode*]
#   Wireless mode.  Must be one of 'Managed' (default) or ???.  Ignored for
#   all but the wireless template.  Managed mode is also commonly known as
#   infrastructure mode.
#
# [*peer_dns*]
#   Use the name servers provided by DHCP?  Either true (default) or false.
#   Ignored for the static templates.
#
# [*peer_ntp*]
#   Use the time servers provided by DHCP?  Either true (default) or false.
#   Ignored for the static templates.
#
# [*persistent_dhcp*]
#   Should the DHCP client persist attempting to gain a lease if it encounters
#   continual failure?  Either true (default) or false.  Ignored for the
#   static templates.
#
# [*psk*]
#   Pre-shared key for wireless encryption.  Ignored for all but the wireless
#   template.
#
# [*stp*]
#   Enable the Spanning Tree Protocol (STP)?  Either true (default) or false.
#   Ignored for all but the bridge templates.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2010-2015 John Florian


define network::interface (
        $template,
        $ensure='present',
        $ip_address=undef,
        $netmask=undef,
        $gateway=undef,
        $bridge=undef,
        $peer_dns=true,
        $peer_ntp=true,
        $stp=true,
        $persistent_dhcp=true,
        $key_mgmt='WPA-PSK',
        $mode='Managed',
        $psk=undef,
        $eth_offload=undef,
    ) {

    validate_re(
        $template, '^((dhcp|static)(-bridge)?|wireless)$',
        "${title}: 'template' must be one of: 'dhcp', 'dhcp-bridge', 'static', 'static-bridge' or 'wireless'"
    )

    validate_re(
        $ensure, '^(present|absent)$',
        "${title}: 'ensure' must be one of: 'absent' or 'present'"
    )

    validate_bool($peer_dns, $peer_ntp, $stp, $persistent_dhcp)

    # Sterilize the name.
    $sterile_name = regsubst($name, '[^\w]+', '_', 'G')

    # The template needs a particular macaddress fact, but it cannot do
    # something like "<%= @macaddress_<%= name %>%>", so this little trick is
    # used here to accomplish the variable interpolation.
    $mac_fact = "macaddress_${name}"
    $interface_hwaddr = inline_template('<%= scope.lookupvar(@mac_fact) %>')

    $notify_service = $network::service ? {
        'legacy' => Service[$::network::params::legacy_services],
        # NetworkManager responds automatically to changes.
        default  => undef,
    }

    file { "/etc/sysconfig/network-scripts/ifcfg-${sterile_name}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        seluser => 'system_u',
        selrole => 'object_r',
        seltype => 'net_conf_t',
        content => template("network/ifcfg-${template}"),
        notify  => $notify_service,
    }

    if $template == 'wireless' and $key_mgmt == 'WPA-PSK' {
        file { "/etc/sysconfig/network-scripts/keys-${sterile_name}":
            ensure  => $ensure,
            owner   => 'root',
            group   => 'root',
            mode    => '0600',
            seluser => 'system_u',
            selrole => 'object_r',
            seltype => 'net_conf_t',
            content => "WPA_PSK='${psk}'\n",
        }
    }

    if $eth_offload and $network::service == 'nm' {
        file { "/etc/NetworkManager/dispatcher.d//00-config-${sterile_name}":
            ensure  => $ensure,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            seluser => 'system_u',
            selrole => 'object_r',
            seltype => 'NetworkManager_initrc_exec_t',
            content => template('network/dispatcher.sh.erb'),
        }
    }

}
