
module Urbit
  class Setting
     attr_reader :category, :contents

    def initialize(ship:, desk:, setting:)
      # puts json
      @ship = ship
      @desk = desk
      @category = setting.first
      @contents = setting.last
      # @contents = JSON.parse(json)
    end

    def to_h
      {
        ship:     @ship.to_h,
        desk:     @desk,
        category: self.category,
        contents: self.contents
      }
    end
  end
end
