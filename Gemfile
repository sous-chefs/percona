source "https://rubygems.org"

chef_version = ENV.fetch("CHEF_VERSION", "12.3.0")

gem "chef", "~> #{chef_version}"
gem "chefspec", "~> 4.2.0"
gem "chef-vault", "~> 2.6.0"

gem "berkshelf", "~> 3.2.4"
gem "foodcritic", "~> 4.0.0"
gem "license_finder", "~> 2.0.4"
gem "rake", "~> 10.4.2"
gem "rubocop", "~> 0.31.0"
gem "serverspec", "~> 2.17.0"

group :integration do
  gem "busser-serverspec", "~> 0.5.6"
  gem "kitchen-docker", "~> 2.1.0"
  gem "kitchen-sync", "~> 1.0.1"
  gem "test-kitchen", "~> 1.4.0"
end
