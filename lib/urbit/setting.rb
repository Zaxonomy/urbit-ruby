
module Urbit
  class Setting
     attr_reader :bucket, :entries

    def initialize(ship:, desk:, setting:)
      @ship = ship
      @desk = desk
      @bucket = setting.first
      @entries = setting.last
    end

    def to_h
      {
        desk:    @desk,
        bucket:  self.bucket,
        entries: self.entries
      }
    end

    def to_s
      "a Setting(#{self.to_h})"
    end
  end
end
