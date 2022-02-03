# frozen_string_literal: true

module Urbit
  class Group
     attr_reader :members, :path

    def initialize(ship:, path:, members:)
      @members = members
      @path    = path
      @ship    = ship
    end

    def to_h
      {
        ship:    @ship,
        path:    self.path,
        members: self.members
      }
    end

    def to_s
      "a Group(#{self.to_h})"
    end
  end
end
