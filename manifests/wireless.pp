# modules/network/manifests/wireless.pp
#
# == Class: network::wireless
#
# Manages a host to support 802.11 wireless network configuration.
#
# It is generally not necessary to include this.  It will automatically be
# included if you provision a network::interface using the wireless template.
#
# === Parameters
#
# ==== Required
#
# ==== Optional
#
# [*packages*]
#   An array of package names needed for a wireless network installation.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# Copyright 2016-2017 John Florian


class network::wireless (
        Array[String[1]]            $packages,
    ) {

    package { $packages:
        ensure => installed,
    }

}
