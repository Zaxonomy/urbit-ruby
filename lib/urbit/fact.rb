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
        return BaseFact.new(channel: channel, event: event)          if contents["json"].nil?                           # TODO: This should be an ErrorFact. DJR 2/3/2022

        # return GroupUpdateFact.new(channel: channel, event: event)   if contents["json"]["groupUpdate"]
        return InitialGroupFact.new(channel: channel, event: event)   if contents["json"]["groupUpdate"]["initial"]

        return SettingsEventFact.new(channel: channel, event: event) if contents["json"]["settings-event"]

        return BaseFact.new(channel: channel, event: event)          if contents["json"]["graph-update"].nil?
        return AddGraphFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-graph"]
        return AddNodesFact.new(channel: channel, event: event)      if contents["json"]["graph-update"]["add-nodes"]
        return RemoveGraphFact.new(channel: channel, event: event)   if contents["json"]["graph-update"]["remove-graph"]

        return BaseFact.new(channel: channel, event: event)
      end
    end
  end
end
