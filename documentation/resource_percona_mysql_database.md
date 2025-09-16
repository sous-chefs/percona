# percona\_mysql\_database

Manage Percona MySQL databases and execute SQL queries on them. Works with Percona Server 8.0+ (where supported). Establishes a control connection to the Percona server using the percona client (ensure it is installed before using this resource).

Terminology: This resource uses inclusive terms (`source/replica`) matching upstream MySQL. See README for details.

See test suite examples in `test/fixtures/cookbooks/test/recipes/user_database.rb`.

## Actions

- create - (default) to create a named database
- drop - to drop a named database
- query - to execute a SQL query

## Properties

Name              | Types             | Description                                                  | Default                                   | Required?
----------------- | ----------------- | ------------------------------------------------------------ | ----------------------------------------- | ---------
`user`            | String            | the username of the control connection                       | `root`                                    | no
`password`        | String            | password of the user used to connect to                      |                                           | no
`host`            | String            | host to connect to                                           | `localhost`                               | no
`port`            | String            | port of the host to connect to                               | `3306`                                    | no
`database_name`   | String            | the name of the database to manage                           | `name` if not specified                   | no
`encoding`        | String            |                                                              | `utf8`                                    | no
`collation`       | String            |                                                              | `utf8_general_ci`                         | no
`sql`             | String            | the SQL query to execute                                     |                                           | no

When `host` has the value `localhost`, it will try to connect using a Unix socket, or TCP/IP if no socket is defined.

### Examples

```ruby
# Create a database
percona_mysql_database 'wordpress-cust01' do
  host '127.0.0.1'
  user 'root'
  password node['wordpress-cust01']['mysql']['initial_root_password']
  action :create
end

# Drop a database
percona_mysql_database 'baz' do
  action :drop
end

# Query a database
percona_mysql_database 'flush the privileges' do
  sql 'flush privileges'
  action :query
end
```

**The `query` action will NOT select a database before running the query, nor return the actual results from the SQL query.**
