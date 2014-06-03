source "https://rubygems.org"

chef_version = ENV.fetch("CHEF_VERSION", "11.10")

gem "chef", "~> #{chef_version}"
gem "chefspec", "~> 3.4" if chef_version =~ /^11/

gem "berkshelf", "~> 3.1.0"
gem "foodcritic", "~> 3.0.0"
gem "rake"
gem "rspec-core", "~> 2.14.8"
gem "rubocop", "~> 0.23.0"
gem "serverspec", "~> 1.7.0"

group :integration do
  gem "busser-serverspec", "~> 0.2.6"
  gem "kitchen-vagrant", "~> 0.15.0"
  gem "test-kitchen", "~> 1.2.1"
end
