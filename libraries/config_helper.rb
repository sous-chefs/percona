require "ipaddr"

module Percona
  # Public: This module provides a helper method for returning a "scope" for a
  # given IP address
  module IPScope
    def for(ipaddress)
      private_ranges = [IPAddr.new("10.0.0.0/8"), IPAddr.new("192.168.0.0/16")]
      loopback_range = IPAddr.new("0.0.0.0/8")

      addr = IPAddr.new(ipaddress)

      if private_ranges.any? { |range| range.include? addr }
        :private
      elsif loopback_range.include?(addr)
        :loopback
      else
        :public
      end
    end
    module_function :for
  end

  # Public: This module provides a helper method for binding to a given IP
  # address
  module ConfigHelper
    def bind_to(node, interface)
      case interface.to_sym
      when :public_ip
        find_public_ip(node)
      when :private_ip
        find_private_ip(node)
      when :loopback
        find_loopback_ip(node)
      else
        find_interface_ip(node, interface)
      end
    end
    module_function :bind_to

    private

    def find_public_ip(node)
      if node["cloud"] && node["cloud"]["public_ipv4"]
        node["cloud"]["public_ipv4"]
      else
        find_ip(node, :private)
      end
    end

    def find_private_ip(node)
      if node["cloud"] && node["cloud"]["local_ipv4"]
        node["cloud"]["local_ipv4"]
      elsif node["cloud"] && node["cloud"]["private_ipv4"]
        node["cloud"]["private_ipv4"]
      elsif node["privateaddress"]
        node["privateaddress"]
      else
        find_ip(node, :private)
      end
    end

    def find_loopback_ip(node)
      find_ip(node, :loopback)
    end

    def find_ip(node, scope)
      node["network"]["interfaces"].each do |_, attrs|
        next unless attrs["addresses"]
        attrs["addresses"].each do |addr, data|
          next unless data["family"] == "inet"
          return addr if IPScope.for(addr) == scope
        end
      end
    end

    def find_interface_ip(node, interface)
      interfaces = node["network"]["interfaces"]
      return unless interfaces[interface]
      addr = interfaces[interface]["addresses"].find do |_, attrs|
        attrs["family"] == "inet"
      end
      addr && addr[0]
    end
    module_function :find_interface_ip
  end
end
