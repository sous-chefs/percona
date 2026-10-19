# AGENTS.md

## Policyfile migration notes

* This cookbook uses `Policyfile.rb` for local and CI dependency resolution.
  Keep Kitchen suite `named_run_list` entries aligned with the test cookbook
  recipes so Policyfile runs preserve the old Berkshelf suite behavior.
* The cookbook is resource-first. Do not reintroduce public recipes or
  attributes; use `test/cookbooks/test/recipes/` for Kitchen coverage examples.

## Product and platform support

* Percona's lifecycle page was checked on July 9, 2026. Its MySQL table was
  updated in June 2026 and lists Percona Server for MySQL, Percona XtraBackup,
  and Percona XtraDB Cluster 8.0.x and 8.4.x as active on their supported OS
  baselines.
* Percona 8.0.x is not available on RHEL 10-compatible platforms or Debian 13,
  so the 8.0 Kitchen suites exclude AlmaLinux 10, CentOS Stream 10, Debian 13,
  and Rocky Linux 10. The matching CI matrix must keep those excludes.
* Percona 8.4.x is supported on RHEL 10-compatible platforms, Debian 13,
  Amazon Linux 2023, Ubuntu 22.04, and Ubuntu 24.04. Keep metadata, Kitchen, and
  CI platform lists aligned when these upstream support statements change.
* Percona 8.4 Debian-family development packages can lag the main client
  package in the upstream apt repository. On July 2, 2026, CI saw
  `percona-server-client=8.4.10-10-1.noble` selected while
  `libperconaserverclient22-dev` was still `8.4.7-7-1.noble` and required the
  matching `percona-server-common` version. The `devel-84` suite is therefore
  excluded on Debian and Ubuntu until Percona publishes matching development
  packages.
