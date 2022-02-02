# frozen_string_literal: true

module Urbit
  module Fact
    class BaseFact
      attr_reader :ack

      def initialize(channel:, event:)
        @channel = channel
        @data = event.data
        @type = event.type
        puts "Received a Fact for [#{channel}] -- [#{@type}] -- [#{@data}]"
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
  end
end
