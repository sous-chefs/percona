if defined?(ChefSpec)
  # rubocop:disable LineLength
  def install_mysql_chef_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_chef_gem, :install, resource_name)
  end

  def install_mysql2_chef_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql2_chef_gem, :install, resource_name)
  end
  # rubocop:enable LineLength
end
