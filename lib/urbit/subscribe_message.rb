module Urbit
  class SubscribeMessage < Message
    attr_reader :path

    def initialize(channel, app, path)
      super(channel, 'subscribe', app)
      @path = path
    end

    def to_h
      {action: self.action, app: self.app, id: self.id, path: self.path, ship: self.ship.untilded_name}
    end
  end
end
