# Percona Cookbook - Project-Specific Instructions

## About This Cookbook

The **Percona cookbook** manages Percona Server for MySQL, XtraBackup, Percona Toolkit, and XtraDB Cluster through custom resources. It is a **resource-driven cookbook**; do not add public recipes or node attributes back as an interface.

## Key Resources

* `percona_repository` - Configures Percona APT/YUM repositories.
* `percona_client` - Installs Percona client packages and optional development headers.
* `percona_server` - Installs and configures Percona Server.
* `percona_backup` - Installs Percona XtraBackup and optional backup grants.
* `percona_toolkit` - Installs Percona Toolkit.
* `percona_cluster` - Installs and configures XtraDB Cluster.
* `percona_replication` - Renders replication configuration.
* `percona_ssl` - Renders SSL certificate material.
* `percona_mysql_database` - Manages MySQL databases.
* `percona_mysql_user` - Manages MySQL users and grants.

## Supported Versions and Platforms

* Percona versions: `8.0` and `8.4`, where upstream Percona publishes supported packages.
* Percona 8.0 is excluded on RHEL 10-compatible platforms and Debian 13.
* Percona 8.4 Debian-family development packages may lag the main client package; keep the `devel-84` Debian/Ubuntu excludes unless upstream packages are verified.
* Keep `metadata.rb`, `kitchen.yml`, `kitchen.dokken.yml`, and `.github/workflows/ci.yml` aligned.

## Testing Structure

* Unit tests live under `spec/unit/resources/` and use `step_into` for custom resources.
* Test cookbook recipes live under `test/cookbooks/test/recipes/`.
* InSpec profiles live under `test/integration/<suite>/` with `inspec.yml` plus `controls/`.
* Dependency resolution uses `Policyfile.rb`; do not reintroduce Berkshelf.

## Development Notes

* Use resource properties for configuration, not cookbook attributes.
* Keep `AGENTS.md` current with upstream support findings and CI decisions.
* Update resource documentation under `documentation/` when properties or behavior change.
* Preserve a real `default` Kitchen suite using `recipe[test::default]`.
