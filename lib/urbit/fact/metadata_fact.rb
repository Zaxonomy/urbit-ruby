# frozen_string_literal: true

module Urbit
  module Fact
    class MetadataUpdateFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.accept if self.for_this_ship?
        # TODO: Remove this debugging once Facts are finalized. DJR 2/3/2022
        puts "Received a #{self.class.name.split('::').last} for [#{channel}] -- [#{@type}] -- [#{@data}]"
      end

      def accept
        # This may be a new incoming Link, add it. If its a dupe, the Links Set will filter it.
        links = channel.ship.links
        self.associations.each do |k, v|
          links << Link.new(path: k, data: v)
        end
        nil
      end

      def associations
        self.root_h["associations"]
      end

      #
      # Attach this new fact as a node to its Graph.
      #
      # def attach_parser
      #   if self.incoming_graph
      #     self.create_parser
      #   end
      # end

      # def incoming_graph
      #   self.ship.graph(resource: self.resource)
      # end

      # def resource
      #   return "~#{self.resource_h["ship"]}/#{self.resource_h["name"]}" unless self.resource_h.nil?
      # end

      # def resource_h
      #   self.root_h["resource"]
      # end

      def root_h
        self.contents["json"]["metadata-update"]
      end

      def to_h
        super.merge!(resource: self.resource)
      end
    end
  end
end
