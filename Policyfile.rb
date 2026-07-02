# frozen_string_literal: true

name 'percona'

run_list 'percona::default'

cookbook 'percona', path: '.'
cookbook 'line', git: 'https://github.com/sous-chefs/line.git', branch: 'main'
cookbook 'test', path: './test/fixtures/cookbooks/test'
cookbook 'yum', git: 'https://github.com/sous-chefs/yum.git', branch: 'main'
cookbook 'yum-epel', git: 'https://github.com/sous-chefs/yum-epel.git', branch: 'main'

{
  'client-80' => 'test::client',
  'client-84' => 'test::client',
  'devel-80' => 'test::client',
  'devel-84' => 'test::client',
  'server-80' => 'test::server',
  'server-84' => 'test::server',
  'source-80' => 'test::source',
  'source-84' => 'test::source',
  'cluster-80' => 'test::cluster',
  'cluster-84' => 'test::cluster',
  'replication-80' => 'test::replication',
  'replication-84' => 'test::replication',
  'resources-80' => 'test::user_database',
  'resources-84' => 'test::user_database',
}.each do |suite, recipe|
  named_run_list suite, recipe
end
