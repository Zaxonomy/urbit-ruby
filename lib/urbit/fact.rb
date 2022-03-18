# frozen_string_literal: true

require_relative 'fact/base_fact'
require_relative 'fact/graph_fact'
require_relative 'fact/group_fact'
require_relative 'fact/settings_fact'

module Urbit
  module Fact
    class << self
      #
      # This is a Factory method to make the proper Fact subclass from a Channel Event.
      #
      def collect(channel:, event:)
        contents = JSON.parse(event.data)

        if contents["json"].nil?
          return SuccessFact.new(channel: channel, event: event) if contents["ok"]
          return ErrorFact.new(channel: channel, event: event)   if contents["err"]
          return EmptyFact.new(channel: channel, event: event)
        end

        if contents["json"]["graph-update"]
          return AddGraphFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-graph"]
          return AddNodesFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-nodes"]
          return RemoveGraphFact.new(channel: channel, event: event)   if contents["json"]["graph-update"]["remove-graph"]
        end

        if (c = contents["json"]["groupUpdate"])
          return AddGroupFact.new(channel: channel, event: event)          if c["addGroup"]
          return AddGroupMemberFact.new(channel: channel, event: event)    if c["addMembers"]
          return AddTagFact.new(channel: channel, event: event)            if c["addTag"]
          return InitialGroupFact.new(channel: channel, event: event)      if c["initial"]
          return InitialGroupGroupFact.new(channel: channel, event: event) if c["initialGroup"]
          return RemoveGroupMemberFact.new(channel: channel, event: event) if c["removeMembers"]
          return RemoveTagFact.new(channel: channel, event: event)         if c["removeTag"]
        end

        if (c = contents["json"]["settings-event"])
          return SettingsEventDelBucketFact.new(channel: channel, event: event) if c["del-bucket"]
          return SettingsEventDelEntryFact.new(channel: channel, event: event)  if c["del-entry"]
          return SettingsEventPutBucketFact.new(channel: channel, event: event) if c["put-bucket"]
          return SettingsEventPutEntryFact.new(channel: channel, event: event)  if c["put-entry"]
        end

        return BaseFact.new(channel: channel, event: event)
      end
    end
  end
end
