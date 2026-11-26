# frozen_string_literal: true

property :host, [String, nil], default: 'localhost', desired_state: false
property :port, [Integer, nil], default: 3306, desired_state: false
property :socket, [String, nil], desired_state: false
property :user, [String, nil], default: 'root', desired_state: false
property :password, [String, nil], sensitive: true, desired_state: false
