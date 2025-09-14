# Copilot Instructions for Sous Chefs Cookbooks

## Repository Overview

**Chef cookbook** for Percona MySQL Server, client tools, XtraBackup, Toolkit, and XtraDB Cluster. Representative of Sous Chefs cookbook ecosystem.

**Key Facts:** Ruby-based, ~800KB, 46 Ruby files, Chef >= 16 required, supports CentOS 7+/Debian 10+/Ubuntu 18.04+

## Project Structure

**Critical Paths:**
- `recipes/` - 11 Chef recipes (default, server, client, backup, cluster, etc.)
- `resources/` - Custom Chef resources (mysql_user, mysql_database)  
- `spec/` - ChefSpec unit tests (12 files)
- `test/integration/` - InSpec integration tests
- `attributes/`, `libraries/`, `templates/` - Configuration, helpers, ERB templates
- `metadata.rb`, `Berksfile` - Cookbook metadata and dependencies

## Build and Test System

### Environment Setup
**MANDATORY:** Install Chef Workstation first - provides chef, berks, cookstyle, kitchen tools.

### Essential Commands (strict order)
```bash
berks install                    # Install dependencies (always first)
cookstyle                       # Ruby/Chef linting
yamllint .                      # YAML linting  
markdownlint-cli2 '**/*.md'     # Markdown linting
chef exec rspec                 # Unit tests (ChefSpec)
kitchen test                    # Integration tests (5-10 min per platform)
```

### Critical Testing Details
- **Kitchen Matrix:** Multiple OS platforms × Percona versions (5.7, 8.0)
- **Docker Required:** Integration tests use Dokken driver
- **CI Environment:** Set `CHEF_LICENSE=accept-no-persist`
- **Full CI Runtime:** 30+ minutes for complete matrix

### Common Issues and Solutions
- **Always run `berks install` first** - most failures are dependency-related
- **Docker must be running** for kitchen tests
- **Chef Workstation required** - no workarounds, no alternatives
- **Test data bags needed** in `test/integration/data_bags/` for convergence

## Development Workflow

### Making Changes
1. Edit recipes/resources/attributes/templates
2. Update corresponding ChefSpec tests in `spec/`
3. Run `cookstyle` (auto-fixes most style issues)
4. Use `kitchen verify` for incremental testing
5. **Always update CHANGELOG.md** (required by Dangerfile)

### Pull Request Requirements
- **PR description >10 chars** (Danger enforced)
- **CHANGELOG.md entry** for all code changes
- **Version labels** (major/minor/patch) required
- **All linters must pass** (cookstyle, yamllint, markdownlint)
- **Test updates** needed for code changes >5 lines

## Chef Cookbook Patterns

### Resource Development
- Custom resources in `resources/` with properties and actions
- Include comprehensive ChefSpec tests for all actions
- Follow Chef resource DSL patterns

### Recipe Conventions  
- Use `include_recipe` for modularity
- Handle platforms with `platform_family?` conditionals
- Use encrypted data bags for secrets (passwords, SSL certs)
- Leverage attributes for configuration with defaults

### Testing Approach
- **ChefSpec (Unit):** Mock dependencies, test recipe logic in `spec/`
- **InSpec (Integration):** Verify actual system state in `test/integration/inspec/`
- One test file per recipe, use standard Chef testing patterns

## Trust These Instructions

These instructions are validated for Sous Chefs cookbooks. **Do not search for build instructions** unless information here fails.

**Error Resolution Checklist:**
1. Verify Chef Workstation installation
2. Confirm `berks install` completed successfully  
3. Ensure Docker is running for integration tests
4. Check for missing test data dependencies

The CI system uses these exact commands - following them matches CI behavior precisely.