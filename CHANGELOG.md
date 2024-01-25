# :arrows_clockwise: Veeam.Diagrammer Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.8] - 2024-01-25

### Chaged

- Added Graphviz libraries to local module folder. (No need to manually install Graphviz)
- Code improvements

## [0.5.7] - 2024-01.13

### Added

- Added support for Physical Infrastructure Diagram.

### Fixed

- Fix [#16](https://github.com/rebelinux/Veeam.Diagrammer/issues/16)

## [0.5.6] - 2024-01.08

### Added

- Added option to specify footer image:
  - Author Name
  - Company Name

### Changed

- Prefer ipv4 address family if available (Get-NodeIP)
- Improved diagram debug feature
- Improved help documentation

### Fixed

- Fix PSScriptAnalyzer warnings

## [0.5.5] - 2023-12.31

### Fixed

- Fix issue with Postgre Database #17

## [0.5.4] - 2023-12.29

### Changed

- Misc fixes

## [0.5.3] - 2023-06.07

### Changed

- Cleaned diagram look and feel

## [0.5.2] - 2023-06.04

### Changed

- Updated README
- Improved the Get-NodeIP function

## [0.5.1] - 2023-05.17

### Fixed

- Fixed error with VBR v12
- Implemented  EnableErrorDebug option to allow error logging
- Fix error with ESXi getManagmentAddresses() when hosts are unavailable

## [0.5.0] - 2022-12.07

### Fixed

- Fixed diagram with no detected Database or Enterprise Manager server.
- Implemented an logic to detect if the infrastructure is available before creating a diagram.

## [0.4.0] - 2022-10.31

### Added

- Added support for Tape Backup Infrastructure diagramming

## [0.3.0] - 2022-10.17

### Added

- Added node support for Enterprise Manager server
- Added debug mode to WAN Accelerator diagram

## [0.2.0] - 2022-10.15

### Added

- Added support for base64 format

### Fixed

- Fix svg output format not displaying nodes icons properly
- Fix svg output format not scaling diagram properly

## [0.1.0] - 2022-08-01

### Added

- Initial Release
  - Added support for SOBR diagramming
  - Added support for Backup Repository diagramming
  - Added support for Backup Proxy diagramming
  - Added support for Wan Accelerator diagramming


