# frozen_string_literal: true

module Urbit
  module Fact
    class GraphUpdateFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
      end

      #
      # Attach this new fact as a node to its Graph.
      #
      def attach_parser
        # puts "Received a graph update for [#{self.ship.graph(resource: self.resource)}]"
        if self.incoming_graph
          # puts "Received an add_graph event: #{self.raw_json} on #{self.resource}"
          self.create_parser
        end
      end

      def graph_update?
        true
      end

      def incoming_graph
        self.ship.graph(resource: self.resource)
      end

      def resource
        return "~#{self.resource_h["ship"]}/#{self.resource_h["name"]}" unless self.resource_h.nil?
      end

      def resource_h
        self.raw_json["resource"]
      end

      def root_h
        self.contents["json"]["graph-update"]
      end

      def to_h
        super.merge!(resource: self.resource)
      end
    end

    class AddGraphFact < GraphUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
      end

      def create_parser
        Urbit::AddGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
      end

      def raw_json
        self.root_h["add-graph"]
      end
    end

    class AddNodesFact < GraphUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
      end

      def create_parser
        Urbit::AddNodesParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
      end

      def raw_json
        self.root_h["add-nodes"]
      end
    end

    class RemoveGraphFact < GraphUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
      end

      def create_parser
        Urbit::RemoveGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json)
      end

      def raw_json
        self.root_h["remove-graph"]
      end

      def resource_h
        self.raw_json
      end
    end
  end
end
