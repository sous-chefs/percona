# frozen_string_literal: true

module Percona
  module Cookbook
    class HashedPassword
      def initialize(hashed_password)
        @hashed_password = hashed_password
      end

      def to_s
        @hashed_password
      end

      module Helper
        def percona_hashed_password(hashed_password)
          HashedPassword.new(hashed_password)
        end
      end
    end
  end
end
