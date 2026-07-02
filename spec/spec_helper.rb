require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.formatter = :documentation
  config.color = true
end
