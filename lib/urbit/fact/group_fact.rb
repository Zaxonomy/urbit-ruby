# frozen_string_literal: true

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
        puts "Group Names: #{self.group_names}"
      end

      def parser
        Urbit::InitialGroupParser.new(with_json: self.raw_json)
      end

      def group_names
        self.parser.group_names
      end

      def raw_json
        self.root_h["initial"]
      end
    end

  end # Module Fact
end # Module Urbit
