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
      "~#{self.resource_node["ship"]}/#{self.resource_node["name"]}"
    end

    def resource_node
      @j["resource"]
    end
  end

  class AddNodesParser
    def initialize(response_json)
      @j = response_json
    end

    def nodes
      nodes = []
      self.nodes_hash.each do |k, v|
        nodes << Urbit::Node.new(k, v)
      end
      nodes
    end

    def nodes_hash
      @j["nodes"]
    end

    def resource
      "~#{self.resource_hash["ship"]}/#{self.resource_hash["name"]}"
    end

    def resource_hash
      @j["resource"]
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

    #
    # Looks like this isn't implemented yet?
    # Answers a %noun in `(unit mark)` format.
    #
    # def mark
    #   r = self.ship.scry('graph-store', "/graph/#{self.to_s}/mark")
    # end

    def messages
      self.fetch_all_nodes if @nodes.empty?
      @nodes
    end

    def newest_messages(count = 100)
      self.fetch_newest_nodes(count) if @nodes.empty?
      @nodes
    end

    def resource
      "#{self.host_ship}/#{self.name}"
    end

    #
    # the canonical printed representation of a Graph
    def to_s
      "a Graph(#{self.resource})"
    end

    private

    def fetch_all_nodes
      r = self.ship.scry('graph-store', "/graph/#{self.resource}/")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (added_graph = AddGraphResponse.new(body["graph-update"]["add-graph"]))
          # Make sure we are adding to the correct graph...
          if (added_graph.resource == self.resource)
            added_graph.graph.each do |k, v|
              self.add_node(Urbit::Node.new(k, v))
            end
          end
        end
      end
      nil
    end

    def fetch_newest_nodes(count)
      r = self.ship.scry('graph-store', "/graph/#{self.resource}/node/siblings/newest/kith/#{count}/")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (parser = AddNodesParser.new(body["graph-update"]["add-nodes"]))
          # Make sure we are adding to the correct graph...
          parser.nodes.each {|n| self.add_node(n)} if (parser.resource == self.resource)
        end
      end
      nil
    end

  end
end
