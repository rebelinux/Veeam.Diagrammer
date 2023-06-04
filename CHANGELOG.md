# :arrows_clockwise: Veeam.Diagrammer Changelog

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


