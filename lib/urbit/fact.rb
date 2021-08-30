require 'urbit/graph'
require 'urbit/node'

module Urbit
  class Fact
    attr_reader :ack

    def initialize(channel:, event:)
      @channel = channel
      @data = event.data
      @type = event.type

      # Attach this fact as a node to its Graph.
      # if self.graph_update?
      #   added_nodes = Urbit::AddNodesResponse.new(self.add_nodes_json)
      #   added_nodes.nodes.each do |k, v|
      #     self.ship.graph(resource: self.resource).add_node(node: Urbit::Node.new(graph: k, node_json: v))
      #   end
      # end
    end

    def add_ack(ack:)
      @ack = :ack
    end

    def add_nodes_json
      return nil unless self.graph_update?
      self.contents["json"]["graph-update"]
    end

    def contents
      JSON.parse(@data)
    end

    def graph_update?
      !self.contents["json"].nil? && !self.contents["json"]["graph-update"].nil?
    end

    def is_acknowledged?
      !@ack.nil?
    end

    def resource
      return nil unless self.graph_update?
      r = self.contents["json"]["graph-update"]["add-nodes"]["resource"]
      "~#{r["ship"]}/#{r["name"]}"
    end

    def ship
      @channel.ship
    end

    def to_h
      {
        ship:            self.ship.to_h,
        resource:        self.resource,
        acknowleged:     self.is_acknowledged?,
        is_graph_update: self.graph_update?
        # contents:        self.contents
      }
    end

    def to_s
      "a Fact(#{self.to_h})"
    end
  end
end
