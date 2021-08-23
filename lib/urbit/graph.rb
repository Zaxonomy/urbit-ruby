require 'set'
require 'urbit/node'

module Urbit
  class AddGraphParser
    def initialize(for_graph:, with_json:)
      @g = for_graph
      @j = with_json
    end

    def add_nodes
      # Make sure we are adding to the correct graph...
      if (@g.resource == self.resource)
        self.nodes_hash.each do |k, v|
          @g.add_node(Urbit::Node.new(@g, v))
        end
      end
      nil
    end

    def nodes_hash
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
    def initialize(for_graph:, with_json:)
      @g = for_graph
      @j = with_json
    end

    def add_nodes
      # Make sure we are adding to the correct graph...
      if (@g.resource == self.resource)
        self.nodes_hash.each do |k, v|
          @g.add_node(Urbit::Node.new(@g, v))
        end
      end
      nil
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
    attr_reader :host_ship_name, :name, :ship

    def initialize(ship, graph_name, host_ship_name)
      @ship           = ship
      @name           = graph_name
      @host_ship_name = host_ship_name
      @nodes          = Set.new
    end

    def add_node(a_node)
      @nodes << a_node
    end

    def fetch_all_nodes
      r = self.ship.scry('graph-store', "/graph/#{self.resource}/")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (parser = AddGraphParser.new(for_graph: self, with_json: body["graph-update"]["add-graph"]))
          parser.add_nodes
        end
      end
      nil
    end

    def fetch_newest_nodes(count)
      r = self.ship.scry('graph-store', "/graph/#{self.resource}/node/siblings/newest/kith/#{count}/")
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (parser = AddNodesParser.new(for_graph: self, with_json: body["graph-update"]["add-nodes"]))
          parser.add_nodes
        end
      end
      nil
    end

    def host_ship
      "~#{@host_ship_name}"
    end

    #
    # This method doesn't have a json mark and thus is not (yet) callable from the Airlock.
    # Answers a %noun in `(unit mark)` format.
    #
    # def mark
    #   r = self.ship.scry('graph-store', "/graph/#{self.to_s}/mark")
    # end

    #
    # Answers all of this Graph's currently attached Nodes, recursively
    # inluding all of the Node's children.
    #
    def nodes
      @all_n = Set.new
      @nodes.each do |n|
        @all_n << n
        n.children.each do |c|
          @all_n << c
        end
      end
      @all_n
    end

    def resource
      "#{self.host_ship}/#{self.name}"
    end

    #
    # the canonical printed representation of a Graph
    def to_s
      "a Graph(#{self.resource})"
    end

  end
end
