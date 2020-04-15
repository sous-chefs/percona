# percona Cookbook CHANGELOG

This file is used to list changes made in each version of the percona cookbook.

## Unreleased

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
