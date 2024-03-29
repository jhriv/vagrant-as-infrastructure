# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.0] - 2022-05-19
### Fixed
- `clean-roles` too greedy; added a roles-local to roles search path
- empty directories now removed in `clean` and `clean-roles` target
- group names have - converted to _
- installs python3 when python is requested, and python3 is available (Debian/Ubuntu)

### Added
- make groups on every - or _ separation
- hostname option
- sample gitignore

## [2.2.2] - 2022-03-08
### Fixed
- `ip` command could not be found on CentOS 7 guests

## [2.2.1] - 2022-03-07
### Added
- `versions` target, for collecting dependency version numbers

## [2.2.0] - 2022-03-07
### Fixed
- Alpine guests now report assigned IP addresses

### CHANGED
- Multiple IPs are listed one per line
- Copyright date in Makefile updated

## [2.1.4] - 2022-03-07
### CHANGED
- Adjust /etc/hosts for alpine guests
- Updated Copyright date

## [2.1.3] - 2021-11-04
### CHANGED
- Update default network range

## [2.1.2] - 2021-09-27
### Fixed
- VAIDIR variable can be either a directory or a pathname prefix

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
