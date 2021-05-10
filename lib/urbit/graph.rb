require 'securerandom'

module Urbit
  class Graph
    attr_reader :name, :host_ship_name

    def initialize(name, host_ship_name)
      @name           = name
      @host_ship_name = host_ship_name
    end

    def to_s
      "a Graph named '#{self.name}' hosted on ~#{self.host_ship_name}"
    end
  end
end
