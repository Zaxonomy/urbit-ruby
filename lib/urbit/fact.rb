require 'urbit/graph'
require 'urbit/node'
require 'urbit/parser'

module Urbit
  class Fact
    attr_reader :ack

    def initialize(channel:, event:)
      @channel = channel
      @data = event.data
      @type = event.type

      # Attach this new fact as a node to its Graph.
      if self.graph_update?
        # puts "Received a graph update for [#{self.ship.graph(resource: self.resource)}]"
        if (incoming_graph = self.ship.graph(resource: self.resource))
          if self.add_graph?
            # puts "Received an add_graph event: #{self.raw_json} on #{self.resource}"
            Urbit::AddGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
          elsif self.add_nodes?
            Urbit::AddNodesParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
          else
            Urbit::RemoveGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json)
          end
        end
      end
    end

    def add_ack(ack:)
      @ack = :ack
    end

    def add_graph?
      return false unless self.graph_update?
      self.contents["json"]["graph-update"]["add-graph"]
    end

    def add_nodes?
      return false unless self.graph_update?
      self.contents["json"]["graph-update"]["add-nodes"]
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

    def raw_json
      return nil unless self.graph_update?
      self.add_nodes? ? self.contents["json"]["graph-update"]["add-nodes"] : self.contents["json"]["graph-update"]["add-graph"]
    end


    def remove_graph?
      return false unless self.graph_update?
      self.contents["json"]["graph-update"]["remove-graph"]
    end

    def resource
      return nil unless self.graph_update?
      r =
        if self.add_nodes?
          self.contents["json"]["graph-update"]["add-nodes"]["resource"]
        elsif self.add_graph?
          self.contents["json"]["graph-update"]["add-graph"]["resource"]
        elsif self.remove_graph?
          self.contents["json"]["graph-update"]["remove-graph"]
        end

      return "~#{r["ship"]}/#{r["name"]}" unless r.nil?
      nil
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
