require 'urbit/node'

module Urbit
  class Graph
    attr_reader :host_ship_name, :nodes, :name, :ship

    def initialize(ship, graph_name, host_ship_name)
      @ship           = ship
      @name           = graph_name
      @host_ship_name = host_ship_name
      @nodes          = []
    end

    def newest_messages
      if @nodes.empty?
        r = self.ship.scry('graph-store', "/newest/~#{self.host_ship_name}/#{self.name}/100")
        if (200 == r[:status])
          body = JSON.parse(r[:body])
          if (added_nodes = body["graph-update"]["add-nodes"])
            # Make sure we are adding to the correct graph...
            if (added_nodes["resource"]["name"] == self.name) && (added_nodes["resource"]["ship"] == self.host_ship_name)
              added_nodes["nodes"].each do |k, v|
                @nodes << Urbit::Node.new(k, v)
              end
            end
          end
        end
      end
      @nodes
    end

    def to_s
      "a Graph named '#{self.name}' hosted on ~#{self.host_ship_name}"
    end
  end
end
