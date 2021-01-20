require "urbit/api/version"

module Urbit
  module Api
    class Config
      def initialize
        require 'yaml'
        config_file = YAML.load_file('_config.yml.example')
        @pier_code = config_file['code']
        @pier_name = config_file['pier']
      end

      def pier_code
        @pier_code
      end

      def pier_name
        @pier_name
      end
    end

    class Error < StandardError;
    end

  end
end
