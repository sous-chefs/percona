# percona Cookbook CHANGELOG

This file is used to list changes made in each version of the percona cookbook.

## Unreleased

### Fixed

- Update apt gpg key
- Fixes for supporting 5.7

### Changed

- Disable enforce_idempotency until we can properly fix it
- Convert to InSpec tests and refactor test cookbook recipes
- Don't install abi_version packages on Debian/Ubuntu
- Standardise files with files in sous-chefs/repo-management

### Removed

- Remove support for Amazon Linux
- Remove support for OpenSUSE

## 0.17.2 - 2020-08-06

### Fixed

- Fix debian_password as a string for testing
- Fix idempotency issues with find_password method

## 0.17.1 - 2020-05-14

- resolved cookstyle error: recipes/access_grants.rb:28:40 convention: `Layout/TrailingWhitespace`
- resolved cookstyle error: recipes/access_grants.rb:28:41 refactor: `ChefModernize/FoodcriticComments`
- resolved cookstyle error: recipes/configure_server.rb:102:25 convention: `Layout/TrailingWhitespace`
- resolved cookstyle error: recipes/configure_server.rb:102:26 refactor: `ChefModernize/FoodcriticComments`
- resolved cookstyle error: recipes/configure_server.rb:170:42 convention: `Layout/TrailingWhitespace`
- resolved cookstyle error: recipes/configure_server.rb:170:43 refactor: `ChefModernize/FoodcriticComments`
- resolved cookstyle error: recipes/replication.rb:28:35 convention: `Layout/TrailingWhitespace`
- resolved cookstyle error: recipes/replication.rb:28:36 refactor: `ChefModernize/FoodcriticComments`

## 0.17.0 - 2020-05-05

- resolved cookstyle error: attributes/default.rb:8:16 warning: `Lint/SendWithMixinArgument`
- resolved cookstyle error: libraries/passwords.rb:23:16 refactor: `ChefModernize/DatabagHelpers`
- resolved cookstyle error: recipes/ssl.rb:17:9 refactor: `ChefModernize/DatabagHelpers`
- Removed unused use_inline_resources and whyrun_supported? methods from the resources
- Removed unused long_description metadata from metadata.rb
- Simplify platform checks inn only_if checks
- Remove the unused .foodcritic file
- Update metadata to point to Sous Chefs
- Migrate to github actions for testing

## [0.16.5]

- Use latest percona GPG keys for yum repo. See [New Percona Package Signing Key Requires Update on RHEL and CentOS](https://www.percona.com/blog/2019/02/05/new-percona-package-signing-key-requires-update-on-rhel-and-centos/)

## [0.16.1] - 2015-06-03

- Many changes

[Unreleased]: https://github.com/sous-chefs/percona/compare/v0.16.1...HEAD
[0.16.1]: https://github.com/sous-chefs/percona/compare/v0.16.0...v0.16.1
