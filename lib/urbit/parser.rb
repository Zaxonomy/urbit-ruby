require 'set'
require 'urbit/node'

module Urbit
  class Parser
    def initialize(for_graph:, with_json:)
      @g = for_graph
      @j = with_json
    end

    #
    # Parses the embedded json and adds any found nodes to the graph.
    # Answers an array of nodes.
    #
    def add_nodes
      added_nodes = []
      # Make sure we are adding to the correct graph...
      if (@g.resource == self.resource)
        self.nodes_hash.each do |k, v|
          added_nodes << (n = Urbit::Node.new(graph: @g, node_json: v))
          @g.add_node(node: n)
        end
      end
      added_nodes
    end

    def resource
      "~#{self.resource_hash["ship"]}/#{self.resource_hash["name"]}"
    end

    def resource_hash
      @j["resource"]
    end
  end

  class AddGraphParser < Parser
    def nodes_hash
      @j["graph"]
    end

  end

  class AddNodesParser < Parser
    def nodes_hash
      @j["nodes"]
    end
  end
end
