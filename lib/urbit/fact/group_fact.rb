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
        self.group_hashes.each do |k, v|
          self.channel.ship.add_group(Group.new(path: k, json: v))
        end
      end

      def parser
        Urbit::InitialGroupParser.new(with_json: self.raw_json)
      end

      def group_hashes
        self.parser.group_hashes
      end

      def raw_json
        self.root_h["initial"]
      end
    end

  end # Module Fact
end # Module Urbit
