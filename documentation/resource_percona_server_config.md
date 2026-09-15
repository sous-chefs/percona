# percona_server_config

Creates Percona Server directories, templates, service state, root config, Debian maintenance config, SSL files, and initial root password.

## Actions

* `:create`
* `:delete`

## Properties

* `server_config`, `backup_config`, `cluster_config`, `extra_config` - Configuration hashes.
* `main_config_file` - Config file path.
* `auto_restart` - Restart service after template updates.
* `skip_passwords` - Skip password-sensitive files and root password update.
* `selinux_module_url` - Optional SELinux module URL for RHEL-family nodes.
