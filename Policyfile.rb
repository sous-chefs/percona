# frozen_string_literal: true

name 'percona'

run_list 'test::default'

cookbook 'percona', path: '.'
cookbook 'test', path: './test/cookbooks/test'
cookbook 'yum', git: 'https://github.com/sous-chefs/yum.git', branch: 'main'

{
  'default' => 'test::default',
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
