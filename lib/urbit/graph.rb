require 'set'
require 'urbit/node'
require 'urbit/parser'

module Urbit
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
    # Finds a single node in this graph by its index.
    # The index here should be the atom representation (as returned by Node#index).
    #
    def node(index:)
      self.fetch_node(index)
    end

    #
    # Answers an array with all of this Graph's currently attached Nodes, recursively
    # inluding all of the Node's children.
    #
    def nodes
      self.fetch_all_nodes if @nodes.empty?
      @all_n = []
      @nodes.each do |n|
        @all_n << n
        n.children.each do |c|
          @all_n << c
        end
      end
      @all_n
    end

    def newest_nodes(count: 10)
      count = 1 if count < 1
      return self.fetch_newest_nodes(count) if @nodes.empty? || @nodes.count < count
      self.nodes.sort.reverse[0..(count - 1)]
    end

    def oldest_nodes(count: 10)
      count = 1 if count < 1
      return self.fetch_oldest_nodes(count) if @nodes.empty? || @nodes.count < count
      self.nodes.sort[0..(count - 1)]
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
      self.fetch_nodes("#{self.graph_resource}/",
                       AddGraphParser,
                       "add-graph")
    end

    def fetch_newest_nodes(count)
      self.fetch_nodes("#{self.graph_resource}/node/siblings/newest/kith/#{count}/",
                       AddNodesParser,
                       "add-nodes")
    end

    def fetch_node(index_atom)
      self.fetch_nodes("#{self.graph_resource}/node/index/kith/#{index_atom}/",
                       AddNodesParser,
                       "add-nodes")
    end

    def fetch_oldest_nodes(count)
      self.fetch_nodes("#{self.graph_resource}/node/siblings/oldest/kith/#{count}/",
                       AddNodesParser,
                       "add-nodes")
    end

    #
    # Answers an array of Nodes that were fetched or an empty array if nothing found.
    #
    def fetch_nodes(endpoint, parser, node)
      r = self.ship.scry('graph-store', endpoint)
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (p = parser.new(for_graph: self, with_json: body["graph-update"][node]))
          return p.add_nodes
        end
      end
      []
    end

    def graph_resource
      "/graph/#{self.resource}"
    end
  end
end
