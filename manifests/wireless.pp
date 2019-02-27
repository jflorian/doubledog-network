#
# == Class: network::wireless
#
# Manages a host to support 802.11 wireless network configuration.
#
# It is generally not necessary to include this.  It will automatically be
# included if you provision a network::interface using the wireless template.
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-network Puppet module.
# Copyright 2016-2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


class network::wireless (
        Array[String[1]]            $packages,
    ) {

    package { $packages:
        ensure => installed,
    }

}
