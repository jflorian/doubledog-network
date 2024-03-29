<!--
This file is part of the doubledog-network Puppet module.
Copyright 2018-2021 John Florian
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

## [3.1.0] 2021-12-09
### Added
- `network::interface::metric` parameter

## [3.0.0] 2020-01-08
### Added
- `network::interface::device` parameter
- `network::interface::essid` parameter
- CentOS 8 support
- Fedora 31 support
### Changed
- BREAKING: wireless interfaces must now have `$namevar` set to the device name (e.g., `wlan0`) instead of the ESSID which must now instead be set via the new parameter (above)
- `network::interface::device` parameter makes it possible for `network::interface::namevar` to be arbitrary now
### Removed
- Fedora 28 support
### Fixed
- `network::wireless` class now ensures that `wpa_supplicant` package is installed
    - Fedora Server 31 setup failed to associate with an WAP without this because it wasn't already installed like with older Minimal images.
- `wireless` template failed to set `MODE=` correctly (or at all)
- disconnect/reconnect of device fails for wireless interfaces because NM wants a device name here, not a connection name or ESSID

## [2.1.0] 2019-10-15
### Changed
- `network::interface::routes` parameter now also supports specifying `gateway`, `metric` and `options` for static routes

## [2.0.0] 2019-09-18
### Added
- Fedora 30 support
- `network::interface::routes` parameter and support for static routes
### Changed
- eliminated a few absolute namespace references (no longer needed with modern Puppet versions)
- The `dhcp` interface template now supports having a static IP address bound to the device in addition to the dynamically obtained one.  Supported with the `nm` service and untested with the `legacy` service.
- connections via NetworkManager are now realized immediately regardless of the `monitor-connection-files` setting
### Removed
- Fedora 27 support
### Fixed
- NetworkManager may not always immediately realize configuration changes.

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
