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

**Defined types:**

**Data types:**

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
A hash whose keys are interface names and whose values are hashes comprising the same parameters you would otherwise pass to Define[network::interface].

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


### Defined types

### Data types

### Facts


## Limitations

Tested on modern Fedora and CentOS releases, but likely to work on any Red Hat variant.  Adaptations for other operating systems should be trivial as this module follows the data-in-module paradigm.  See `data/common.yaml` for the most likely obstructions.  If "one size can't fit all", the value should be moved from `data/common.yaml` to `data/os/%{facts.os.name}.yaml` instead.  See `hiera.yaml` for how this is handled.

## Development

Contributions are welcome via pull requests.  All code should generally be compliant with puppet-lint.
