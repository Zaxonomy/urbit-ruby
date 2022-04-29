# frozen_string_literal: true

require 'urbit/bucket'

module Urbit
  class Setting
    attr_accessor :buckets
    attr_reader :desk, :ship

    def initialize(ship:, desk:, buckets:)
      @ship    = ship
      @desk    = desk
      @buckets = Set.new
      buckets.each {|k, v| @buckets << Bucket.new(setting: self, name: k, entries: v)}
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

    def add_bucket(name:, entries:)
      msg = {
        "put-bucket": {
          "bucket-key": "#{name}",
          "desk":       "#{self.desk}",
          "bucket":     entries
        }
      }
      self.ship.poke(app: 'settings-store', mark: 'settings-event', message: msg)
      nil
    end

    def entries(bucket:)
      self[bucket: bucket].entries
    end

    def remove_bucket(name:)
      msg = {
        "del-bucket": {
          "bucket-key": "#{name}",
          "desk":       "#{self.desk}"
        }
      }
      self.ship.poke(app: 'settings-store', mark: 'settings-event', message: msg)
      nil
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
end
