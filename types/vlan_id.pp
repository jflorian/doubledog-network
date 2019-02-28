#
# == Type: Network::Vlan_id
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


type Network::Vlan_id = Variant[
    Integer[1, 4094],
    # Kludge for Hiera interpolation forcing values to String.
    Pattern[/^([1-3]?\d{1,3}|40[0-8]\d|409[0-4])$/]
]
