source "https://rubygems.org"

chef_version = ENV.fetch("CHEF_VERSION", "12.1.0")

gem "chef", "~> #{chef_version}"
gem "chefspec", "~> 4.2.0" if chef_version > "11.0"
gem "chef-vault", "~> 2.5.0"

gem "berkshelf", "~> 3.2.2"
gem "foodcritic", "~> 4.0.0"
gem "license_finder", "~> 1.2.0"
gem "rake", "~> 10.4.2"
gem "rubocop", "~> 0.29.1"
gem "serverspec", "~> 2.10.0"

group :integration do
  gem "busser-serverspec", "~> 0.5.3"
  gem "kitchen-vagrant", "~> 0.15.0"
  gem "test-kitchen", "~> 1.3.1"
end
