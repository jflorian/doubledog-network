<!--
This file is part of the doubledog-network Puppet module.
Copyright 2018-2019 John Florian <jflorian@doubledog.org>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# network

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with network](#setup)
    * [What network affects](#what-network-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with network](#beginning-with-network)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defined types](#defined-types)
    * [Data types](#data-types)
    * [Facts](#facts)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module lets you manage network.

## Setup

### What network Affects

### Setup Requirements

### Beginning with network

## Usage

## Reference

**Classes:**

* [network](#network-class)
* [network::wireless](#networkwireless-class)

**Defined types:**

* [network::interface](#networkinterface-defined-type)

**Data types:**

* [Network::Vlan\_id](#NetworkVlan_id-data-type)
* [Network::Vlan\_id](#NetworkTemplate-data-type)

**Facts:**


### Classes

#### network class

This class manages a host's network configuration.

##### `domain` (required)
Name of the network domain.

##### `service` (required)
Use `'legacy'` (default) or `'nm'` (NetworkManager) service.

##### `enable`
The selected *service* is to be started at boot.  Either `true` (default) or `false`.

##### `ensure`
The selected *service* is to be `'running'` (default) or `'stopped'`.  Alternatively, a Boolean value may also be used with `true` equivalent to `'running'` and `false` equivalent to `'stopped'`.

##### `interfaces`
A hash whose keys are interface names and whose values are hashes comprising the same parameters you would otherwise pass to the [network::interface](#networkinterface-defined-type) defined type.

##### `legacy_packages`
An array of package names needed for a legacy network installation.  The default should be correct for supported platforms.

##### `legacy_service`
The name of the legacy network service.  The default should be correct for supported platforms.

##### `legacy_service_provider`
The name of the Puppet provider to manage the legacy network service.  The default should be correct for supported platforms.

##### `manager_packages`
An array of package names needed for a NetworkManager installation.  The default should be correct for supported platforms.

##### `manager_service`
The name of the NetworkManager service.  The default should be correct for supported platforms.

##### `name_servers`
Array of IP address strings that provide DNS address resolution.  Typically not required for hosts with interfaces configured exclusively by DHCP.  If set, this will cause the name resolver configuration to be managed.

##### `unmanaged`
Array of strings stating which network interface devices, if any, that NetworkManager is to leave unmanaged.  The format for each is described in the section called "Device List Format" of NetworkManager.conf(5).  This is ignored if *service* is `'legacy'`.


#### network::wireless class

This class manages the packages required for wireless networking.  It is included, as needed, by the [network](#network-class) class.

##### `packages`
An array of package names needed for a wireless network installation.  The default should be correct for supported platforms.


### Defined types

#### network::interface defined type

This defined type manages a network interface configuration.

##### `namevar` (required)
Name of the interface, e.g., `'eth0'`.  If *template* is `'wireless'` this must be set to the Extended Service Set Identification (ESSID) of the wireless network.

##### `template` (required)
The particular template to be used.  Must be one of `'dhcp'`, `'dhcp-bridge'`, `'static'`, `'static-bridge'` or `'wireless'`.  The `'wireless'` template assumes a DHCP configuration and is only supported when `$network::service` is `'nm'` (NetworkManager).

##### `ensure`
Instance is to be `'present'` (default) or `'absent'`.

##### `bridge`
Name of the associated bridge interface, if any.  Ignored when *template* is one of `'dhcp-bridge'`, `'static-bridge'` or `'wireless'`.

##### `country`
Country code for CRDA when *template* is `'wireless'`.  Ignored for all other templates.

##### `eth_offload`
Any device-specific options supported by `ethtool`'s `-K` option expressed as a simple string passed along unmodified.  E.g., `'gso off'`.

##### `gateway`
The default route IP address to be assigned to the interface.  Recommended when *template* is `'static'` or `'static-bridge'` and ignored for all others.

##### `ip_address`
The IP address to be assigned to the interface.  Required when *template* is `'static'` or `'static-bridge'` and ignored for all others.

##### `key_mgmt`
Key management method for wireless encryption.  Must be one of `'WPA-PSK'` (default) or ???.  Required when *template* is `'wireless'` and ignored for all others.

##### `mac_address`
The MAC address to be assigned to the interface.  This is not used for identifying/matching a physical interface but rather to override what the manufacturer assigned.

##### `mode`
Wireless mode.  Must be one of `'Managed'` (default, also known as infrastructure mode) or ???.  Required when *template* is `'wireless'` and ignored for all others.

##### `netmask`
The network mask for this interface.  Required when *template* is `'static'` or `'static-bridge'` and ignored for all others.

##### `peer_dns`
Use the name servers provided by DHCP?  Either `true` (default) or `false`.  Ignored when *template* is `'static'` or `'static-bridge'`.

##### `peer_ntp`
Use the time servers provided by DHCP?  Either true (default) or false.  Ignored when *template* is `'static'` or `'static-bridge'`.

##### `persistent_dhcp`
Should the DHCP client persist attempting to gain a lease if it encounters continual failure?  Either `true` (default) or `false`.  Ignored when *template* is `'static'` or `'static-bridge'`.

##### `psk`
Pre-shared key for wireless encryption.  Required when *template* is `'wireless'` and ignored for all others.

##### `stp`
Enable the Spanning Tree Protocol (STP)?  Either `true` (default) or `false`.  Ignored unless *template* is `'static-bridge'`.

##### `vlan`
If set with a VLAN ID, this interface will tag all outbound packets with this ID and only accept packets tagged with this ID.  Valid IDs range from 1 to 4094.

This alone does not affect the name of the interface so it is necessary to make the tagged interface distinct from the base interface.  One common convention is to set *namevar* so that its the base interface name followed by a dot followed by the VLAN ID, e.g., `'eth0.123'`.


### Data types

#### `Network::Template` data type

Matches acceptable values for the *template* parameter of the [network::interface](#networkinterface-defined-type) defined type.


#### `Network::Vlan_id` data type

Matches acceptable values for a VLAN ID, specifically a positive integer no less than 1 and no greater than 4094.  This also accepts a string so long as the value matches the same restrictions.


### Facts


## Limitations

Tested on modern Fedora and CentOS releases, but likely to work on any Red Hat variant.  Adaptations for other operating systems should be trivial as this module follows the data-in-module paradigm.  See `data/common.yaml` for the most likely obstructions.  If "one size can't fit all", the value should be moved from `data/common.yaml` to `data/os/%{facts.os.name}.yaml` instead.  See `hiera.yaml` for how this is handled.

## Development

Contributions are welcome via pull requests.  All code should generally be compliant with puppet-lint.
