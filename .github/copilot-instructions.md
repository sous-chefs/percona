# Copilot Instructions for Sous Chefs Cookbooks

## Repository Overview

This is a **Chef cookbook** repository maintained by the Sous Chefs community. The Percona cookbook installs and configures Percona MySQL Server, client tools, XtraBackup, Percona Toolkit, and XtraDB Cluster components. This cookbook is representative of the Sous Chefs cookbook ecosystem.

**Repository Stats:**
- **Type:** Chef Cookbook (Ruby-based configuration management)
- **Size:** ~800KB, 46 Ruby files, 11 YAML files  
- **Dependencies:** Requires Chef >= 16, depends on yum-epel and line cookbooks
- **Supported Platforms:** CentOS 7+, Debian 10+, Ubuntu 18.04+ LTS (64-bit)

## Project Structure

**Key Directories:**
- `recipes/` - Chef recipe files (11 recipes including default, server, client, backup, cluster)
- `attributes/` - Default attribute files for configuration
- `resources/` - Custom Chef resources (mysql_user, mysql_database)  
- `libraries/` - Helper methods and password management
- `templates/` - ERB templates for config files (my.cnf, grants.sql, etc.)
- `spec/` - ChefSpec unit tests (12 test files)
- `test/integration/` - InSpec integration tests with test kitchen
- `documentation/` - Resource documentation

**Important Files:**
- `metadata.rb` - Cookbook metadata, dependencies, and supported platforms
- `Berksfile` - Cookbook dependency management
- `kitchen.yml` - Test Kitchen configuration for integration testing
- `kitchen.dokken.yml` - Docker-based testing configuration  
- `chefignore` - Files to exclude from cookbook packaging

## Build and Test System

### Environment Setup
**ALWAYS install Chef Workstation first:** All cookbook development requires Chef Workstation which provides chef, berks, cookstyle, kitchen, and other essential tools.

### Core Commands (in order)

1. **Dependency Installation:**
   ```bash
   berks install
   ```
   Downloads cookbook dependencies to `~/.berkshelf/cookbooks/`. Always run before testing.

2. **Linting (must pass CI):**
   ```bash
   cookstyle              # Ruby/Chef style linting
   yamllint .             # YAML file linting  
   markdownlint-cli2 '**/*.md'  # Markdown linting
   ```

3. **Unit Testing:**
   ```bash
   chef exec rspec        # Runs ChefSpec unit tests
   ```
   Tests are in `spec/` directory. Must pass for CI.

4. **Integration Testing:**
   ```bash
   kitchen test           # Full integration test suite
   kitchen test [SUITE]-[PLATFORM]  # Test specific combination
   ```
   Uses Test Kitchen with Docker (Dokken driver) or Vagrant. Tests take 5-10 minutes per platform.

### Important Testing Notes

- **Kitchen Matrix:** Tests run against multiple OS platforms (CentOS, Debian, Ubuntu, AlmaLinux) with different Percona versions (5.7, 8.0)
- **CI Requirements:** All lint, unit, and integration tests must pass for merge
- **Test Suites:** client, server, backup, toolkit, cluster, replication, resources with different version matrices
- **Docker Requirement:** Integration tests use Docker with Dokken driver
- **Timing:** Full test matrix takes 30+ minutes in CI

### Common Issues and Solutions

**Build Failures:**
- Always run `berks install` before testing - dependency issues are common
- Kitchen tests require Docker and adequate disk space  
- MySQL/Percona installation can fail due to repository key issues
- Test convergence requires proper test data bags in `test/integration/data_bags/`

**Environment Setup:**
- Chef Workstation installation is mandatory - no workarounds
- Set `CHEF_LICENSE=accept-no-persist` environment variable for testing
- Docker daemon must be running for kitchen-dokken tests

## Development Workflow

### Making Changes
1. **Code Changes:** Edit recipes, resources, attributes, or templates
2. **Update Tests:** Modify corresponding ChefSpec tests in `spec/`
3. **Lint Early:** Run `cookstyle` after each change - fixes most style issues automatically
4. **Test Incrementally:** Use `kitchen verify` to run tests without full convergence
5. **Update CHANGELOG.md:** Required for all code changes per Dangerfile rules

### Validation Pipeline
```bash
# Complete validation sequence
berks install
cookstyle
yamllint .
chef exec rspec  
kitchen test [specific-suite] # Test your changes
```

### Pull Request Requirements
- **Summary Required:** PR description must be >10 characters (enforced by Danger)
- **Changelog Required:** All code changes need CHANGELOG.md entry
- **Version Labels:** Add major/minor/patch labels to PR
- **Test Coverage:** Code changes >5 lines need corresponding test updates
- **Linting:** All linters must pass (cookstyle, yamllint, markdownlint)

## Chef-Specific Conventions

### Resource Development
- Custom resources are in `resources/` directory
- Follow Chef resource patterns with properties, actions, and providers
- Include comprehensive ChefSpec tests for all resource actions

### Recipe Patterns  
- Use `include_recipe` for modular composition
- Handle platform differences with `platform_family?` conditionals
- Encrypted data bags for sensitive data (passwords, SSL certs)
- Use attributes for configuration with sensible defaults

### Template Usage
- ERB templates in `templates/default/` directory
- Use cookbook attributes and helper methods for dynamic content
- Handle platform-specific configurations within templates

## Testing Patterns

### ChefSpec Unit Tests
- One test file per recipe in `spec/` directory
- Mock external dependencies and resources
- Test recipe inclusion, resource creation, and attribute usage
- Use `expect(chef_run).to include_recipe` patterns

### InSpec Integration Tests  
- Tests in `test/integration/inspec/` directory
- Verify actual system state after cookbook convergence
- Test service status, file existence, package installation
- Use InSpec resource matchers like `describe service()` and `describe file()`

## Trust These Instructions

These instructions are specifically validated for Sous Chefs cookbooks. **Do not search for build instructions** unless information here is incomplete or produces errors. The Sous Chefs ecosystem follows consistent patterns across all cookbooks.

**When encountering errors:**
1. Verify Chef Workstation is properly installed
2. Check that `berks install` completed successfully  
3. Ensure Docker is running for integration tests
4. Review error messages for missing dependencies or test data

The CI system uses the exact same commands documented here, so following these instructions will match the CI environment behavior.