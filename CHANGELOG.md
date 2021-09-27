# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### CHANGED
- Updated Copyright date
- Formatted license for 80 columns

## [2.1.1] - 2021-09-27
### Fixed
- Renamed etc-hosts playbook

## [2.1.0] - 2021-09-27
### Changed
- Ansible files migrated to separate subdirectory

## [2.0.0] - 2021-09-27
### Added
- Shell providers can accept an array of scripts
- Able to set sshuser name
- Alpine support

### Changed
- roles.yml renamed to requirements.yml
- Ansible set to use debug stdout callback
- Updated list of available boxes

## [1.3.4] - 2020-08-18
### Fixed
- Misleading "no main.yml" warning

## [1.3.3] - 2020-08-18
### Changed
- Updated default box

## [1.3.2] - 2020-01-16
### Changed
- Moved GUESTS to top of GUESTS.rb.sample
- Reformatted in-file documentation

## [1.3.1] - 2019-12-05
### Fixed
- Machine settings are per-machine for all providers

## [1.3.0] - 2019-12-05
### Fixed
- Provider can be only per vagrant up invocation

## [1.2.0] - 2019-12-04
### Added
- Per machine selectable provider
- Support Parallels as a provider

## [1.1.0] - 2018-10-18
### Added
- `file`, `shell`, and `ansible` provisioners in Vagrantfile/GUESTS.rb

### Changed
- Default box is `ubuntu/bionic64`
- Installs python/python-apt on boxes with `debian` or `ubuntu` in their name
- Only running boxes have their ssh configurations queried

## [1.0.1] - 2018-10-17
### Added
- `copyright` and `license` targets

## [1.0.0] - 2018-10-16
### Added
- First Public Release
