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

    def contents
      JSON.parse(@data)
    end

    def graph_update?
      false
    end

    def is_acknowledged?
      !@ack.nil?
    end

    def raw_json
      nil
    end

    def resource
      return nil if self.resource_h.nil?
      return "~#{self.resource_h["ship"]}/#{self.resource_h["name"]}" unless self.resource_h.nil?
    end

    def resource_h
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

    def graph_update?
      true
    end

    def raw_json
      self.contents["json"]["graph-update"]["add-graph"]
    end

    def resource_h
      self.raw_json["resource"]
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

    def graph_update?
      true
    end

    def raw_json
      self.contents["json"]["graph-update"]["add-nodes"]
    end

    def resource_h
      self.raw_json["resource"]
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

    def graph_update?
      true
    end

    def raw_json
      self.contents["json"]["graph-update"]["remove-graph"]
    end

    def resource_h
      self.raw_json
    end
  end
end
