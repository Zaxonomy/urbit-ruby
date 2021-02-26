require 'json'

module Urbit
  class SubscribeMessage < Message
    attr_reader :path

    def initialize(channel)
      @action  = 'subscribe'
      @app     = 'graph-store'
      @channel = channel
      @id      = 0
      @path    = '/updates'
    end

    def to_h
      {action: action, app: app, id: id, path: path, ship: ship.untilded_name}
    end
  end
end
