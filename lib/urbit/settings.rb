# frozen_string_literal: true

require 'urbit/bucket'

module Urbit
  class Setting
    attr_reader :buckets, :desk

    def initialize(desk:, buckets:)
      @desk    = desk
      @buckets = Set.new
      buckets.each {|k, v| @buckets << Bucket.new(name: k, entries: v)}
    end

    def ==(another_group)
      another_setting.desk == self.desk
    end

    def <=>(another_group)
      self.desk <=> another_group.desk
    end

    def [](bucket:)
      self.buckets.select {|b| bucket == b.name}.first
    end

    def entries(bucket:)
      self[bucket: bucket].entries
    end

    def to_h
      {
        desk:    @desk,
        buckets: self.buckets,
      }
    end

    def to_s
      "a Setting(#{self.to_h})"
    end

    def to_string
      "desk: #{self.desk}\n  buckets: #{self.buckets.collect {|b| b.to_string}}"
    end
  end

  class Settings < Set
    attr_accessor :channel

    class << self
      def load(ship:)
        channel = ship.subscribe(app: 'settings-store', path: '/all')
        scry = ship.scry(app: "settings-store", path: "/all", mark: "json")
        # scry = self.scry(app: "settings-store", path: "/desk/#{desk}", mark: "json")
        s = Settings.new(channel: channel)
        if scry[:body]
          body = JSON.parse scry[:body]
          body["all"].each do |k, v|  # At this level the keys are the desks and the values are the buckets
            s << Setting.new(desk: k, buckets: v)
          end
        end
        s
      end
    end

    def initialize(channel:)
      @channel = channel
      @hash    = {}
    end

    def [](desk:)
      self.select {|s| desk == s.desk}.first
    end

    def list
      self.each {|s| puts s.to_string}
      nil
    end
  end

end
