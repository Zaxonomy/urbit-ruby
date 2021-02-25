require 'json'

module Urbit
  class SubscribeMessage < Message
    attr_reader :path

    def initialize(channel)
      @channel = channel
      @action  = 'subscribe'
      @app     = 'graph-store'
      @path    = '/updates'
    end

    def request_body
      [{
        action: action,
        app:    app,
        id:     channel.next_id,
        path:   path,
        ship:   ship.untilded_name
      }].to_json
    end

    def ship
      channel.ship
    end
  end
end
