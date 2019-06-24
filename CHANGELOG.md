<!--
This file is part of the doubledog-network Puppet module.
Copyright 2018-2019 John Florian
SPDX-License-Identifier: GPL-3.0-or-later

Template

## [VERSION] WIP
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

-->

# Change log

All notable changes to this project (since v1.0.0) will be documented in this file.  The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [1.2.0] WIP
### Added
### Changed
### Deprecated
### Removed
- Fedora 27 support
### Fixed
### Security

## [1.1.1] 2019-03-20
### Fixed
- NetworkManager-1.4.0 now defaults to MAC cloning on WiFi devices.  While good for privacy, it's incompatible with MAC address filtering that may be employed on WAPs.  For now it will just be disabled on all WiFi devices for backwards compatibility with the expectations of this module.

## [1.1.0] 2019-02-28
### Added
- support for Fedora 27-29
- dependency on `doubledog-ddolib`
- `Network::Vlan_id` data type
- `Network::Template` data type
- `network::interface::unmanaged` parameter
### Changed
- parameter documentation moved from manifests to the `README.md` file
- all templates now have `.erb` suffix
- leverage `Ddolib` data types
- `network::interface::vlan_id` now uses the new `Network::Vlan_id` data type
- `network::interface::template` now uses the new `Network::Template` data type
### Removed
- support for Fedora 24-25

## [1.0.0 and prior] 2018-12-15

This and prior releases predate this project's keeping of a formal CHANGELOG.  If you are truly curious, see the Git history.
