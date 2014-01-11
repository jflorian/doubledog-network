# modules/network/manifests/interface.pp
#
# == Define: network::interface
#
# Installs an interface configuration file for the network services.
#
# === Parameters
#
# [*namevar*]
#   Name of the interface, e.g., 'eth0'.  Required.
#
# [*ensure*]
#   Instance is to be 'present' (default) or 'absent'.
#
# [*template*]
#   The particular template to be used.  Must be one of 'dhcp', 'dhcp-bridge',
#   'static' or 'static-bridge'.
#
# [*ip_address*]
#   The address to be assigned to the interface.  Required for the static
#   templates and ignored for the dhcp templates.
#
# [*gateway*]
#   The default route address to be assigned to the interface.  Recommended
#   for the static templates and ignored for the dhcp templates.
#
# [*bridge*]
#   Name of the associated bridge interface, if any.  Optional.  Ignored for
#   the bridge templates.
#
# [*peer_dns*]
#   Use the name servers provided by DHCP?  Must be one of 'yes' (default) or
#   'no'.  Ignored for the static templates.
#
# [*peer_ntp*]
#   Use the time servers provided by DHCP?  Must be one of 'yes' (default) or
#   'no'.  Ignored for the static templates.
#
# [*stp*]
#   Enable the Spanning Tree Protocol (STP)?  Must be one of 'yes' (default)
#   or 'no'.  Ignored for all but the bridge templates.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>


define network::interface (
        $ensure='present',
        $template='standard',
        $ip_address=undef,
        $netmask=undef,
        $gateway=undef,
        $bridge=undef,
        $peer_dns='yes',
        $peer_ntp='yes',
        $stp='yes',
    ) {

    # The template needs a particular macaddress fact, but it cannot do
    # something like "<%= @macaddress_<%= name %>%>", so this little trick is
    # used here to accomplish the variable interpolation.
    $mac_fact = "macaddress_${name}"
    $interface_hwaddr = inline_template("<%= scope.lookupvar(@mac_fact) %>")

    file { "/etc/sysconfig/network-scripts/ifcfg-${name}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        selrole => 'object_r',
        seltype => 'net_conf_t',
        seluser => 'system_u',
        content => template("network/ifcfg-${template}"),
        notify  => Service['network'],
    }

}
