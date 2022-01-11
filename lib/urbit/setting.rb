
module Urbit
  class Setting
     attr_reader :category, :contents

    def initialize(ship:, desk:, setting:)
      @ship = ship
      @desk = desk
      @category = setting.first
      @contents = setting.last
    end

    def to_h
      {
        desk:     @desk,
        category: self.category,
        contents: self.contents
      }
    end

    def to_s
      "a Setting(#{self.to_h})"
    end
  end
end
