# modules/network/manifests/definitions/interface.pp
#
# Synopsis:
#       Installs a network interface configuration file.
#
# Parameters:
#       Name__________  Default_______  Description___________________________
#
#       name                            interface name (e.g., 'eth0')
#       ensure          present         configuration is to be present/absent
#       template        standard        particular template to be used
#
# Requires:
#       Class['network']
#
# Example usage:
#
#       include network
#
#       network::interface { 'acme':
#           notify  => Service['SERVICE_NAME'],
#           source  => 'puppet:///private-host/acme.conf',
#       }


define network::interface (
        $ensure='present',
        $template='standard',
        $ip_address=undef,
        $netmask=undef,
        $bridge=undef,
        $peer_dns='yes'
    ) {

    # The template needs a particular macaddress fact, but it cannot do
    # something like "<%= macaddress_<%= name %>%>", so this little trick is
    # used here to accomplish the variable interpolation.
    $mac_fact = "macaddress_${name}"
    $interface_hwaddr = inline_template("<%= scope.lookupvar(mac_fact) %>")

    file { "/etc/sysconfig/network-scripts/ifcfg-${name}":
        content => template("network/ifcfg-${template}"),
        ensure  => $ensure,
        group   => 'root',
        mode    => '0640',
        notify  => Service['network'],
        owner   => 'root',
        selrole => 'object_r',
        seltype => 'net_conf_t',
        seluser => 'system_u',
    }

}
