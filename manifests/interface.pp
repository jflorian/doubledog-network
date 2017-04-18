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
# [*bridge*]
#   Name of the associated bridge interface, if any.  Ignored for the bridge
#   and wireless templates.
#
# [*country*]
#   Country code for CRDA when using the wireless template.  Ignored for all
#   other templates.
#
# [*eth_offload*]
#   Any device-specific options supported by ethtool's -K option expressed as
#   a simple string passed along unmodified.  E.g., "gso off".
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
# [*mac_address*]
#   The MAC address to be assigned to the interface.  This is not used for
#   identifying a physical interface but rather to override what the
#   manufacturer of the interface used.
#
# [*mode*]
#   Wireless mode.  Must be one of 'Managed' (default) or ???.  Ignored for
#   all but the wireless template.  Managed mode is also commonly known as
#   infrastructure mode.
#
# [*netmask*]
#   The network mask for this interface.  Required for the static templates
#   and ignored for the dhcp and wireless templates.
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
# [*vlan*]
#   If set with a VLAN ID, this interface will make itself a member of that
#   VLAN, assuming the switch permits this.  Valid VLAN IDs range from 1 to
#   4096.
#
#   This does not affect the name of the interface so it is necessary to
#   include the VLAN ID as part of the "namevar", e.g., 'eth0.123'.  This
#   ensures that your Puppet manifests can distinguish between the base
#   Network::Interface instance and any VLAN Network::Interface instances.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2010-2017 John Florian


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
        content => template("network/ifcfg-${template}"),
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
