source "https://rubygems.org"

chef_version = ENV.fetch("CHEF_VERSION", "12.18.31")

gem "chef", "~> #{chef_version}"
gem "chef-vault"
gem "chefspec"

gem "berkshelf"
gem "foodcritic"
gem "license_finder"
gem "rake"
gem "rubocop"
gem "serverspec"

group :integration do
  gem "busser-serverspec"
  gem "kitchen-docker"
  gem "kitchen-sync"
  gem "test-kitchen"
end
