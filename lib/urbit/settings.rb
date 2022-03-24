# frozen_string_literal: true

module Urbit
  class Settings < Set
    class << self
      def load(ship:)
        ship.subscribe(app: 'settings-store', path: '/all')
        scry = ship.scry(app: "settings-store", path: "/all", mark: "json")
        # scry = self.scry(app: "settings-store", path: "/desk/#{desk}", mark: "json")
        s = Settings.new
        if scry[:body]
          body = JSON.parse scry[:body]
          body["all"].each do |k, v|  # At this level the keys are the desks and the values are the buckets
            s << Setting.new(ship: ship, desk: k, buckets: v)
          end
        end
        s
      end
    end

    def initialize
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
