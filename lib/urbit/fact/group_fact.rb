# frozen_string_literal: true

require 'urbit/group'

module Urbit
  module Fact
    class GroupUpdateFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
      end

      def root_h
        self.contents["json"]["groupUpdate"]
      end
    end

    class InitialGroupFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.parser.groups.each {|g| self.channel.ship.add_group(g)}
      end

      def parser
        Urbit::InitialGroupParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["initial"]
      end
    end

  end # Module Fact
end # Module Urbit