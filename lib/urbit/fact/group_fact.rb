# frozen_string_literal: true

require 'urbit/group'
require 'urbit/group_parser'

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

    class AddGroupFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.add(self.parser.group)
      end

      def parser
        Urbit::AddGroupParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["addGroup"]
      end
    end

    class AddGroupMemberFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.add_members group_path: self.parser.resource, ships: self.parser.ships
      end

      def parser
        Urbit::ChangeMemberParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["addMembers"]
      end
    end

    class AddTagFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.add_tag group_path: self.parser.resource, ships: self.parser.ships, tag: self.parser.tag
      end

      def parser
        Urbit::ChangeTagParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["addTag"]
      end
    end

    class InitialGroupFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.parser.groups.each {|g| self.channel.ship.groups.add(g)}
      end

      def parser
        Urbit::InitialGroupParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["initial"]
      end
    end

    class InitialGroupGroupFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.add(self.parser.group)
      end

      def parser
        Urbit::InitialGroupGroupParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["initialGroup"]
      end
    end

    class RemoveGroupMemberFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.remove_members group_path: self.parser.resource, ships: self.parser.ships
      end

      def parser
        Urbit::ChangeMemberParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["removeMembers"]
      end
    end

    class RemoveTagFact < GroupUpdateFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.channel.ship.groups.remove_tag group_path: self.parser.resource, ships: self.parser.ships, tag: self.parser.tag
      end

      def parser
        Urbit::ChangeTagParser.new(with_json: self.raw_json)
      end

      def raw_json
        self.root_h["removeTag"]
      end
    end

  end # Module Fact
end # Module Urbit
