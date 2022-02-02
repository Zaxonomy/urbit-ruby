
module Urbit
  class Setting
     attr_reader :bucket

    def initialize(ship:, desk:, setting:)
      @ship = ship
      @desk = desk
      @bucket = setting.first
      @entries = setting.last
    end

    def entries(bucket: nil)
      return @entries if (bucket.nil? || @bucket == bucket)
      {}
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
