#
# == Type: Network::Template
#
# === Authors
#
#   John Florian <jflorian@doubledog.org>
#
# === Copyright
#
# This file is part of the doubledog-network Puppet module.
# Copyright 2019 John Florian
# SPDX-License-Identifier: GPL-3.0-or-later


type Network::Template = Enum[
    'dhcp',
    'dhcp-bridge',
    'static',
    'static-bridge',
    'wireless',
]
