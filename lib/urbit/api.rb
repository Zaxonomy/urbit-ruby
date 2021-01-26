require "urbit/api/version"

module Urbit
  module Api
    class Config
      def initialize
        require 'yaml'
        config_file = YAML.load_file('_config.yml.example')
        @ship_code = config_file['code']
        @ship_name = config_file['ship']
      end

      def ship_code
        @ship_code
      end

      def ship_name
        @ship_name
      end
    end

    class Error < StandardError;
    end

  end
end
