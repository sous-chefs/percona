# percona Cookbook CHANGELOG

This file is used to list changes made in each version of the percona cookbook.

## Unreleased

## 3.4.5 - *2023-12-21*

## 3.4.4 - *2023-09-28*

## 3.4.3 - *2023-09-04*

## 3.4.2 - *2023-07-10*

## 3.4.1 - *2023-06-14*

- Fix adjustment of open files limit within systemd unit

## 3.4.0 - *2023-06-07*

- Avoid changing the perms on /tmp
- Remove duplicate configuration line
- Avoid duplicating mysqld configuration section in my.cnf
- Remove the open file limit from the systemd unit since it is already set in my.cnf anyway

## 3.3.1 - *2023-05-17*

## 3.3.0 - *2023-04-25*

- Fixed the user key in the ctrl_hash for the run_query method in the mysql_user custom resource
- Updated ctrl_hash (now user_hash) parameters to validate if a user can login using username@host instead of username@ctrl_host
- Wrapped password substring in single quotes to protect from special characters in sql_command_string helper method
- Updated default encoding and collate in 8.0 to `utf8mb4` and `utf8mb4_0900_ai_ci` respectively
- Fixed 8.0 client rpm dependency conflict on centos 7
- Stop running tests for Server and Client 5.6
- Change test behaviour to not enable jemalloc on RHEL 9.

## 3.2.11 - *2023-04-25*

Standardise files with files in sous-chefs/repo-management

## 3.2.10 - *2023-04-07*

Standardise files with files in sous-chefs/repo-management

## 3.2.9 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 3.2.8 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 3.2.7 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 3.2.6 - *2023-03-20*

Standardise files with files in sous-chefs/repo-management

## 3.2.5 - *2023-03-15*

Standardise files with files in sous-chefs/repo-management

## 3.2.4 - *2023-02-23*

Standardise files with files in sous-chefs/repo-management

## 3.2.3 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 3.2.2 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 3.2.1 - *2022-12-08*

Standardise files with files in sous-chefs/repo-management

## 3.2.0 - *2022-08-18*

- Remove `myisam_repair_threads` for < 5.7 as it's been deprecated
- Remove delivery and move to calling RSpec directly via a reusable workflow
- Update tested platforms
- Add support to Alma Linux & Rocky Linux
- Update default encoding when using 8.0 to `utf8mb3` to fix idempotency issues
- Fix management of server `my.cnf`
- Set `manage_symlink_source` to `false` and set `force_unlink` to `true` to fix idempotency on Debian based systems
- Fix issue when testing on Debian dokken images by removing mailutils (and thus mysql-common)

## 3.1.3 - *2022-02-17*

- Standardise files with files in sous-chefs/repo-management

## 3.1.2 - *2022-02-08*

- Remove delivery folder

## 3.1.1 - *2022-01-03*

- Fix root password setting for version >= 5.7

## 3.1.0 - *2021-10-04*

- Use `dnf_module` resource from `yum` cookbook instead of manually disabling module

## 3.0.0 - *2021-09-17*

- Chef 17 updates: enable `unified_mode` on all resources
- Remove dependency on openssl cookbook and create `percona_secure_random` method to replace that functionality
- Remove dependency on chef-vault cookbook and require Chef >= 16
- Use full gpg key id for apt repos and switch to using keyserver.ubuntu.com
- Move mysql dnf module disabling to before yum repos

## 2.1.2 - *2021-08-30*

- Standardise files with files in sous-chefs/repo-management

## 2.1.1 - *2021-06-01*

- Standardise files with files in sous-chefs/repo-management

## 2.1.0 - *2021-01-19*

- Fix error when granting multi-word privileges (ex. `REPLICATION CLIENT`) to users through `percona_mysql_user`
- Remove support for Ubuntu 16.04

## 2.0.1 - *2020-12-15*

- Fix links to resources in README

## 2.0.0 - 2020-10-23

- Add `percona_mysql_database` resource for creating, querying and removing databases
- Add `percona_mysql_user` resource for creating, modifying and removing database users

- Remove `mysql_chef_gem` and `mysql2_chef_gem` providers in favor of the `percona_mysql_database` and `percona_mysql_user` resources

## 1.1.1 - 2020-09-16

- resolved cookstyle error: libraries/helpers.rb:125:1 refactor: `ChefCorrectness/IncorrectLibraryInjection`

## 1.1.0 - 2020-08-20

- Add devel package attribute to client recipe

## 1.0.0 - 2020-08-14

- Add support for Debian 10 for 5.7 only
- Add support for Ubuntu 20.04 for 5.7 only
- Add support for CentOS 8
- Add cluster suite and tests to test cluster recipe
- Add support for Percona 8.0 and default to that version
- Re-add ChefSpec tests
- Add ssl suite and tests for ssl recipe
- Add master suite and tests for testing the replication recipe
- Suite to test compatibility with Chef 13
@2.0.1

- Update apt gpg key
- Fixes for supporting 5.7
- Fix manage_symlink_source warning with template[/etc/mysql/my.cnf]
- Don't remove mysql-libs on RHEL
- jemalloc package installation and path setup for all platforms
- Fixed enabled ChefSpec tests
- Use the correct syntax on 8.0 for SSL replication
- Use correct cert path for master/slave
- Fix issue when trying to set node['percona']['version'] in a recipe

- Convert to InSpec tests and refactor test cookbook recipes
- Don't install abi_version packages on Debian/Ubuntu
- Standardise files with files in sous-chefs/repo-management
- Move client package installation for cluster to cluster recipe

- Remove support for Amazon Linux
- Remove support for OpenSUSE
- Remove support for Debian 8 (EOL)
- Remove support for Fedora / Scientific
- Remove support for CentOS 6
- Remove references to EOL 5.5 release

### Deprecated

- Deprecate monitoring recipe
- Use new inclusive terminology and add deprecation warning for old terms

## 0.17.2 - 2020-08-06

@2.0.1

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

[0.16.1]: https://github.com/sous-chefs/percona/compare/v0.16.0...v0.16.1
