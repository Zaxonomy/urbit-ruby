require 'set'
require 'urbit/node'

module Urbit
  class AddGraphResponse
    def initialize(response_json)
      @j = response_json
    end

    def graph
      @j["graph"]
    end

    def resource
      @j["resource"]
    end

    def resource_name
      "~#{self.resource["ship"]}/#{self.resource["name"]}"
    end
  end

  class Graph
    attr_reader :host_ship_name, :nodes, :name, :ship

    def initialize(ship, graph_name, host_ship_name)
      @ship           = ship
      @name           = graph_name
      @host_ship_name = host_ship_name
      @nodes          = Set.new
    end

    def add_node(a_node)
      @nodes << a_node
    end

    def host_ship
      "~#{@host_ship_name}"
    end

    def messages
      self.fetch_all_nodes if @nodes.empty?
      @nodes
    end

    def newest_messages
      self.fetch_newest_messages if @nodes.empty?
      @nodes
    end

    def resource_name
      "#{self.host_ship}/#{self.name}"
    end

    #
    # the canonical printed representation of a Graph
    def to_s
      self.resource_name
    end

    private

    def fetch_all_nodes
      r = self.ship.scry('graph-store', "/graph/#{self.to_s}/")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (added_graph = AddGraphResponse.new(body["graph-update"]["add-graph"]))
          # Make sure we are adding to the correct graph...
          if (added_graph.resource_name == self.resource_name)
            added_graph.graph.each do |k, v|
              self.add_node(Urbit::Node.new(k, v))
            end
          end
        end
      end
      nil
    end

    def fetch_newest_messages
      r = self.ship.scry('graph-store', "/newest/~#{self.host_ship_name}/#{self.name}/100")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (added_nodes = body["graph-update"]["add-nodes"])
          # Make sure we are adding to the correct graph...
          if (added_nodes["resource"]["name"] == self.name) && (added_nodes["resource"]["ship"] == self.host_ship_name)
            added_nodes["nodes"].each do |k, v|
              self.add_node(Urbit::Node.new(k, v))
            end
          end
        end
      end
      nil
    end

  end
end
