# frozen_string_literal: true

module Urbit
  class Links < Set
    class << self
    end

    def initialize
      @hash    = {}
    end

    def [](path:)
      self.select {|l| path == l.path}.first
    end

    def list
      self.each {|l| puts l.to_string}
      nil
    end

    def load(ship:)
      ship.subscribe(app: 'metadata-store', path: '/all')
      nil
    end
  end

  class Link
    attr_reader :path, :data

    def initialize(path:, data:)
      @path    = path
      @data    = data
    end

    def ==(another)
      another.path == self.path
    end

    def <=>(another)
      self.path <=> another.path
    end

    # scry = ship.scry(app: "metadata-store", path: "/all", mark: "json")
    # # scry = self.scry(app: "settings-store", path: "/desk/#{desk}", mark: "json")
    # s = Settings.new
    # if scry[:body]
    #   body = JSON.parse scry[:body]
    #   body["all"].each do |k, v|  # At this level the keys are the desks and the values are the buckets
    #     s << Setting.new(ship: ship, desk: k, buckets: v)
    #   end
    # end
    # s
  end
end
