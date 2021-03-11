module Urbit
  class SubscribeMessage < Message
    attr_reader :path

    def initialize(channel, app, path)
      @action  = 'subscribe'
      @app     = app
      @channel = channel
      @id      = 0
      @path    = path
    end

    def to_h
      {action: action, app: app, id: id, path: path, ship: ship.untilded_name}
    end
  end
end
