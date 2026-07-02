# AGENTS.md

## Policyfile migration notes

* This cookbook uses `Policyfile.rb` for local and CI dependency resolution.
  Keep Kitchen suite `named_run_list` entries aligned with the test cookbook
  recipes so Policyfile runs preserve the old Berkshelf suite behavior.
* Percona 8.4 Debian-family development packages can lag the main client
  package in the upstream apt repository. On July 2, 2026, CI saw
  `percona-server-client=8.4.10-10-1.noble` selected while
  `libperconaserverclient22-dev` was still `8.4.7-7-1.noble` and required the
  matching `percona-server-common` version. The `devel-84` suite is therefore
  excluded on Debian and Ubuntu until Percona publishes matching development
  packages.
