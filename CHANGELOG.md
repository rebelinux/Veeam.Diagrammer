# :arrows_clockwise: Veeam.Diagrammer Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.29] - 2025-05-16

### Changed

- Update module version to 0.6.29
- Enhance column size handling in diagram generation scripts
- Improved column size logic for various diagram components to dynamically adjust based on the number of items, ensuring better layout and readability.
- Enhanced error handling and verbose output for better debugging and user feedback during diagram generation.

## [0.6.28] - 2025-05-14

### Added

- Add Esxi/HyperV StandAlone Host to the Backup Infrastructure diagram

### Changed

- Bump module version to v0.6.28

### Fixed

- Fix [#65](https://github.com/rebelinux/Veeam.Diagrammer/issues/65)
- Resolve [#217](https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR/issues/217)

## [0.6.27] - 2025-05-10

### Changed

- Update version to 0.6.27
- Update `Diagrammer.Core` module version to 0.2.26

### Removed

- Eliminate unused rules from `PSScriptAnalyzer` settings to streamline code analysis

## [0.6.26] - 2025-04-30

### Added

- Add support for Cloud Backup Repositories

### Changed

- Bump version to 0.6.26
- Improve error handling in diagram generation
- Enhance user notifications in New-VeeamDiagram function

## [0.6.25] - 2025-04-29

### Added

- Add support for Cloud Backup Repositories

### Changed

- Bump version to 0.6.25
- Improved Infrastructure diagram
- Enhance diagram generation functions

### Fixed

- Resolve an issue where Backup Repositories fail to display when no SAN infrastructure is present

## [0.6.24] - 2025-04-18

### Changed

- Bump version to 0.6.24
- Increase minimum Diagrammer.Core version requirement to 0.2.24
- improve spacing in diagram generation functions.
- Disable run from PowerShell ISE
- Improved Infrastructure diagram

## [0.6.23] - 2025-04-15

### Changed

- Increase Diagrammer.Core minimum version requirement (v0.2.23)

## [0.6.22] - 2025-04-09

### Added

- Add HyperV information to the Backup Infrastructure diagram

### Changed

- Enforce connections to the Domain Controller using its Fully Qualified Domain Name (FQDN) instead of its IP address
- Increase Diagrammer.Core minimum version requirement (v0.2.21)

## [0.6.21] - 2025-03-05

### Fixed

- Fix Infrastructure diagram Repository text not getting generated

## [0.6.20] - 2025-03-05

### Changed

- Increase Diagrammer.Core minimum version requirement (v0.2.19)

### Fixed

- Fix diagram label not getting displayed after Diagrammer.Core v0.2.19 update

## [0.6.19] - 2025-03-03

### Added

- Add Entra ID Tenant information to the Infrastructure diagram
- Add Esxi StandAlone servers to the VMware Backup Proxy diagram
- Add Hyper-V Infrastructure information to the Hyper-V Backup Proxy diagram

### Changed

- Improve Backup Repository diagram layout
- Increase Diagrammer.Core minimum version requirement (v0.2.17)

### Fixed

- Fix error when the user used to connect to the Backup Server isn't a Local Administrator on the server.

## [0.6.18] - 2024-12-11

### Added

- Add Entra ID Tenant information to the Infrastructure diagram

### Fixed

- Improve Graphviz Cluster space with less than 1 object to display (Get-DiagBackupToFileProxy)
- Fix Google Cloud Storage repository not displaying a icon

## [0.6.17] - 2024-11-28

### Fixed

- Fix [#53](https://github.com/rebelinux/Veeam.Diagrammer/issues/53)
- Fix issue with diagramming empty Object Storage Graphviz cluster

## [0.6.16] - 2024-11-20

### Changed

- Increase Diagrammer.Core minimum version requirement
- Migrated Protection Group diagram to use Get-DiaHTMLSubGraph cmdlet

### Fixed

- Remove hardcoded vCenter server from query

## [0.6.15] - 2024-11-13

### Fixed

- Improve Graphviz Cluster space with less than 1 object to display

## [0.6.14] - 2024-11-13

### Fixed

- Fix issue with diagramming empty vSphere Cluster


## [0.6.13] - 2024-11-13

### Added

- Add support for displaying HyperVisor Information
  - vCenter information
  - vSphere Cluster Information
    - Esxi Host table

### Changed

- Increase Diagrammer.Core minimum version requirement
- Improve logging

## [0.6.12] - 2024-10-30

### Added

- Add code to properly display diskspace information

### Fixed

- Fix [#43](https://github.com/rebelinux/Veeam.Diagrammer/issues/43)

## [0.6.11] - 2024-10-20

### Changed

- Increase Diagrammer.Core minimum version requirement

### Fixed

- Fix bug in Service Provider section

## [0.6.10] - 2024-10-19

### Changed

- Enhance Diagram design
- Increase Diagrammer.Core minimum version requirement

## [0.6.9] - 2024-10-10

### Added

- Add DependaBot action

### Fixed

- Fix a issue on error handling

## [0.6.8] - 2024-09-22

### Added

- Add diagram theme (Black/White/Neon)
- Add SureBackup support
  - Application Group
  - Virtual Lab

### Fixed

- Fix logic on Backup Server component detection (Backup, Database & EM Server)

## [0.6.7] - 2024-09-16

### Changed

- Increase Diagrammer.Core minimum version requirement

### Fixed

- Fix Backup Server section if Enterprise Manager is collocated with the Backup Server
- Fix a issue in the SOBR diagram if there are multiple CapacityExtend configured
- Fix a issue in the SOBR diagram if there are multiple Extend configured

## [0.6.6] - 2024-09-12

### Fixed

- Fix error with Base64 format

## [0.6.5] - 2024-09-11

### Added

- Add code to better recover from errors

### Changed

- Enhance the way EnableErrorDebug option works
- Increased Diagrammer.Core minimum version requirement (v0.2.6)

### Fixed

- Fix error in SOBR ForEach-Object section
- Remove error with Write-PSCriboMessage module
- Fix error with NFS/LinuxHardened repository type

## [0.6.4] - 2024-09-07

### Changed

- Increased Diagrammer.Core minimum version requirement

## [0.6.3] - 2024-09-07

### Added

- Add Backup Infrastructure diagram

### Removed

- Remove unused icons

## [0.6.2] - 2024-08-31

### Changed

- Migrate diagrams to use Get-DiaHTMLNodeTable

## [0.6.1] - 2024-08-31

### Added

- Add support for NAS Repository (Backup-to-Repository)

### Changed

- Allow EDGE to connect between Subgraph Clusters
- Update Diagrammer.Core minimum to v0.2.3

### Fixed

- Fix veeam module version detection

## [0.6.0] - 2024-05-09

### Changed

- Migrated helper modules to Diagrammer.Core

### Removed

- Removed Graphviz binaries (Now part of Diagrammer.Core module)
- Removed Backup-to-All diagram

### Fixed

- Fix for empty ProtectedGroup condition

## [0.5.9] - 2024-02-15

### Added

- Added Get-HTMLNodeTable cmdlet

### Changed

- Improved diagram layout
- Improved Get-HTMLTable cmdlet (Now allow MultiColumn table)

### Fixed

- Fixed CodeQL security alerts
- Fix for PSGraph hidden node interfering in edge calculation


## [0.5.8] - 2024-01-25

### Changed

- Added Graphviz libraries to local module folder. (No need to manually install Graphviz)
- Code improvements

### Fixed

- Added missing dll files on Graphviz binaries

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


