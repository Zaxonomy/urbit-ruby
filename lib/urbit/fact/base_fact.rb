# frozen_string_literal: true

module Urbit
  module Fact
    class BaseFact
      attr_reader :ack, :channel, :data, :type

      def initialize(channel:, event:)
        @channel = channel
        @data = event.data
        @type = event.type
      end

      def add_ack(ack:)
        @ack = :ack
      end

      def contents
        JSON.parse(@data)
      end

      def create_parser
        nil
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

    class EmptyFact < BaseFact
    end

    class ErrorFact < BaseFact
      def error
        self.contents["err"]
      end

      def response
        self.contents["response"]
      end

      def to_h
        super.merge!({
          error:    self.error,
          response: self.response,
        })
      end
    end

    class SuccessFact < BaseFact
      def code
        self.contents["ok"]
      end

      def response
        self.contents["response"]
      end

      def to_h
        super.merge!({
          code:     self.code,
          response: self.response,
        })
      end

    end
  end
end
