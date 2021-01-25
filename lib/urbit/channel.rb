require 'faraday'
require 'SecureRandom'

module Urbit
  module Api

    class Channel
      def initialize(name)
        @key = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
        @name = name
      end

      def key
        @key
      end

      def name
        @name
      end
    end

  end
end
