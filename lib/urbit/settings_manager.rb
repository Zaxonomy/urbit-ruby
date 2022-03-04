# frozen_string_literal: true

require 'urbit/setting'

module Urbit
  class SettingsManager
    attr_accessor :channel, :settings

    def initialize(channel:)
      @channel  = channel
      @settings = Set.new
    end

    def load(ship:)
      scry = ship.scry(app: "settings-store", path: "/all", mark: "json")
      # scry = self.scry(app: "settings-store", path: "/desk/#{desk}", mark: "json")
      if scry[:body]
        body = JSON.parse scry[:body]
        body["all"].each do |k, v|  # At this level the keys are the desks and the values are the buckets
          @settings << Setting.new(desk: k, buckets: v)
        end
      end
    end

    def list
      self.settings.map {|s| s.to_s}.join("\n")
    end

  end

end
