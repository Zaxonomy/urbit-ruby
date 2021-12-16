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
    end

    #
    # This is a Facotry method to make the proper Fact subclass from
    # a Channel Event.
    #
    def self.collect(channel:, event:)
      contents = JSON.parse(event.data)
      return Fact.new(channel: channel, event: event)            if (contents["json"].nil? || contents["json"]["graph-update"].nil?)
      return AddGraphFact.new(channel: channel, event: event)    if contents["json"]["graph-update"]["add-graph"]
      return AddNodesFact.new(channel: channel, event: event)    if contents["json"]["graph-update"]["add-nodes"]
      return RemoveGraphFact.new(channel: channel, event: event) if contents["json"]["graph-update"]["remove-graph"]
      return Fact.new(channel: channel, event: event)
    end

    def add_ack(ack:)
      @ack = :ack
    end

    def add_graph?
      false
    end

    def add_nodes?
      return false
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
      return false
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

  class AddGraphFact < Fact
    def initialize(channel:, event:)
      super channel: channel, event: event

      # Attach this new fact as a node to its Graph.
      # puts "Received a graph update for [#{self.ship.graph(resource: self.resource)}]"
      if (incoming_graph = self.ship.graph(resource: self.resource))
        # puts "Received an add_graph event: #{self.raw_json} on #{self.resource}"
        Urbit::AddGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
      end
    end

    def add_graph?
      true
    end
  end

  class AddNodesFact < Fact
    def initialize(channel:, event:)
      super channel: channel, event: event

      # Attach this new fact as a node to its Graph.
      # puts "Received a graph update for [#{self.ship.graph(resource: self.resource)}]"
      if (incoming_graph = self.ship.graph(resource: self.resource))
        # puts "Received an add_graph event: #{self.raw_json} on #{self.resource}"
        Urbit::AddNodesParser.new(for_graph: incoming_graph,  with_json: self.raw_json).add_nodes
      end
    end

    def add_nodes?
      true
    end
  end

  class RemoveGraphFact < Fact
    def initialize(channel:, event:)
      super channel: channel, event: event

      # Attach this new fact as a node to its Graph.
      # puts "Received a graph update for [#{self.ship.graph(resource: self.resource)}]"
      if (incoming_graph = self.ship.graph(resource: self.resource))
        # puts "Received an add_graph event: #{self.raw_json} on #{self.resource}"
        Urbit::RemoveGraphParser.new(for_graph: incoming_graph,  with_json: self.raw_json)
      end
    end

    def remove_graph?
      true
    end
  end
end
