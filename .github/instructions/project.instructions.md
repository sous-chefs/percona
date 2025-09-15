# Percona Cookbook - Project-Specific Instructions

## About This Cookbook

The **Percona cookbook** installs and configures Percona MySQL client and/or server components, with optional XtraBackup, Percona Toolkit, and XtraDB Cluster support. This is a **recipe-driven cookbook** that also provides custom resources for database and user management.

## Key Components

### Recipes (Primary Interface)

- `percona` (default) - Includes client recipe
- `percona::client` - Installs Percona MySQL client libraries  
- `percona::server` - Installs and configures Percona MySQL server
- `percona::backup` - Installs Percona XtraBackup hot backup software
- `percona::toolkit` - Installs Percona Toolkit command-line tools
- `percona::cluster` - Sets up XtraDB Cluster for high availability
- `percona::package_repo` - Sets up package repository
- `percona::replication` - Configures MySQL replication
- `percona::ssl` - Configures SSL certificates

### Custom Resources

- `percona_mysql_database` - Manages MySQL databases
- `percona_mysql_user` - Manages MySQL users and grants

### Supported Versions & Platforms

**Percona MySQL Versions:** 8.0 (default), 5.7 (legacy support)
**Platforms:** CentOS 7+, Debian 10+, Ubuntu 18.04+ LTS

## Configuration Patterns

### Version Selection

```ruby
# Set Percona version in attributes
node['percona']['version'] = '8.0'  # Default
node['percona']['version'] = '5.7'  # Legacy
```

### Server Configuration

```ruby
# Key server attributes (platform-specific paths)
node['percona']['server']['socket']               # MySQL socket path
node['percona']['server']['default_storage_engine'] # InnoDB/innodb
node['percona']['server']['includedir']           # Config include directory
node['percona']['server']['pidfile']              # PID file location
```

### Database & User Management

```ruby
# Using custom resources
percona_mysql_database 'example_db' do
  connection mysql_connection_info
  action :create
end

percona_mysql_user 'app_user' do
  connection mysql_connection_info 
  password 'secure_password'
  database_name 'example_db'
  privileges [:all]
  action :create
end
```

## Testing Structure

### Test Kitchen Suites

- `client-56` - Tests client installation with Percona 5.6
- `server-56` - Tests server installation with Percona 5.6  
- `server-80` - Tests server installation with Percona 8.0
- `cluster` - Tests XtraDB Cluster setup

### Test Fixtures

Located in `test/fixtures/cookbooks/test/` - demonstrates proper cookbook usage patterns including:

- Client-only installations
- Server configurations
- Cluster setups
- Database and user management examples

### Data Bags Required

Test data bags in `test/integration/data_bags/` for:

- MySQL root passwords
- Application database credentials
- SSL certificate data

## Platform-Specific Behavior

### Debian/Ubuntu

- Socket: `/var/run/mysqld/mysqld.sock`
- PID: `/var/run/mysqld/mysqld.pid`
- Include dir: `/etc/mysql/conf.d/`
- Storage engine: `InnoDB` (capitalized)

### RHEL/CentOS

- Socket: `/var/lib/mysql/mysql.sock`  
- PID: `/var/lib/mysql/mysqld.pid`
- Include dir: `` (empty)
- Storage engine: `innodb` (lowercase)

## Dependencies

### Required Cookbooks

- `yum` - Package management for RHEL platforms
- `yum-epel` - EPEL repository for additional packages
- `line` - File editing utilities

### External Dependencies

- Percona APT/YUM repositories (managed by `package_repo` recipe)
- Internet access for package downloads during convergence

## Common Issues

### Repository Setup

Always include `percona::package_repo` before installing packages, or use dependency ordering in recipes.

### SELinux

Set `node['percona']['selinux_module_url']` if custom SELinux policies are needed for XtraDB Cluster.

### Version Compatibility

- Percona 8.0 requires different configuration patterns than 5.7
- Test both versions when making changes to server recipes
- XtraDB Cluster configuration varies significantly between versions

## Development Notes

When modifying this cookbook:

1. **Version Support**: Test changes against both 5.7 and 8.0 versions
2. **Platform Testing**: Verify on Debian, Ubuntu, and CentOS platforms  
3. **Resource Testing**: Update both recipe and resource tests when changing database/user management
4. **Security**: Use encrypted data bags for passwords and certificates
5. **Clustering**: XtraDB Cluster changes require multi-node testing (handled by CI)
