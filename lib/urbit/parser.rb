require 'set'
require 'urbit/node'

module Urbit
  class Parser
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
