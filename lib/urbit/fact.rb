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
      puts "Received a Fact for [#{channel}] -- [#{@type}] -- [#{@data}]"
    end

    #
    # This is a Facotry method to make the proper Fact subclass from
    # a Channel Event.
    #
    def self.collect(channel:, event:)
      contents = JSON.parse(event.data)
      return Fact.new(channel: channel, event: event)              if contents["json"].nil?
      return SettingsEventFact.new(channel: channel, event: event) if contents["json"]["settings-event"]

      return Fact.new(channel: channel, event: event)              if contents["json"]["graph-update"].nil?
      return AddGraphFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-graph"]
      return AddNodesFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-nodes"]
      return RemoveGraphFact.new(channel: channel, event: event)   if contents["json"]["graph-update"]["remove-graph"]

      return Fact.new(channel: channel, event: event)
    end

    def add_ack(ack:)
      @ack = :ack
    end

    def contents
      JSON.parse(@data)
    end

    def for_this_ship?
      self.ship == @channel.ship
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

    def ship
      @channel.ship
    end

    def to_h
      {
        ship:            self.ship.to_h,
        acknowleged:     self.is_acknowledged?,
        is_graph_update: self.graph_update?
      }
    end

    def to_s
      "a #{self.class.name}(#{self.to_h})"
    end
  end

  class GraphUpdateFact < Fact
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

    def create_parser
      nil
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

  class SettingsEventFact < Fact
    def initialize(channel:, event:)
      super channel: channel, event: event

      if self.for_this_ship?
        # See if we already have this setting, if no add it, if yes update it.
        if (entries = channel.ship.setting(bucket: self.bucket))
          entries[self.entry] = self.value
        end
      end
    end

    def bucket
      self.contents["bucket-key"]
    end

    def contents
      JSON.parse(@data)["json"]["settings-event"]["put-entry"]
    end

    def desk
      self.contents["desk"]
    end

    def entry
      self.contents["entry-key"]
    end

    def to_h
      super.merge!({
        bucket: self.bucket,
        desk:   self.desk,
        entry:  self.entry,
        value:  self.value
      })
    end

    def value
      self.contents["value"]
    end
  end
end
