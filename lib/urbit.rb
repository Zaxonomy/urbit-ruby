require "urbit/config"
require "urbit/ship"
require "urbit/version"

# This is the main namespace for Urbit.
#
# It provides a method to create {Urbit::Ship} objects.
#
# @example Helpful class method `.new` to create {Urbit::Ship} objects.
#   ship = Urbit.new(port: 80)
#   conn.get '/'
module Urbit
  class << self
    def connect(**config_options)
      config = Urbit::Config.new(**config_options)
      ship = Urbit::Ship.new(config: config)
      ship.login
    end

    def new(**config_options)
      config = Urbit::Config.new(**config_options)
      Urbit::Ship.new(config: config)
    end
  end
end
