# frozen_string_literal: true

require_relative '../link.rb'

module Urbit
  module Fact
    class MetadataUpdateFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.accept if self.for_this_ship?
        # TODO: Remove this debugging once Facts are finalized. DJR 2/3/2022
        # puts "Received a #{self.class.name.split('::').last} for [#{channel}] -- [#{@type}] -- [#{@data}]"
      end

      def accept
        # This is an new incoming Link, add it. If its a dupe, the Links Set will filter it.
        links = channel.ship.links
        self.associations.each do |k, v|
          links << Link.new(chain: links, path: k, data: v)
        end
        nil
      end

      def associations
        # An ugly hack around the fact that when you first join a group there is another
        # useless "initial-update" enclosing hash.
        unless (a = self.root_h["associations"])
          return self.root_h["initial-group"]["associations"]
        end
        a
      end

      def root_h
        self.contents["json"]["metadata-update"]
      end

      def to_h
        super.merge!(resource: self.resource)
      end
    end
  end
end
