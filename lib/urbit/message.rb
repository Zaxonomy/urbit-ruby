require 'json'

module Urbit
  class Message
    attr_reader :action, :app, :channel, :id, :json, :mark

    def initialize(channel, id, action, app, mark, json)
      @action  = action
      @channel = channel
      @id      = id
      @app     = app
      @mark    = mark
      @json    = json
    end

    def channel_url
      "#{self.ship.config.api_base_url}/~/channel/#{self.channel.key}"
    end

    def request_body
      [{
        action: action,
        app: app,
        id: id,
        json: json,
        mark: mark,
        ship: ship.untilded_name
      }].to_json
    end

    def ship
      self.channel.ship
    end

    def transmit
      response = Faraday.put(channel_url) do |req|
        req.headers['Cookie'] = self.ship.cookie
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
        puts req.body.to_s
      end

      # TODO
      # handle_error if response.status != 204
      response
    end
  end

  class CloseMessage < Message
    def initialize(channel, id)
      @channel = channel
      @ship    = channel.ship
      @id      = id
      @action  = 'delete'
    end

    def request_body
      [{
        id:     id,
        action: action
      }].to_json
    end
  end

  class SubscribeMessage < Message
    attr_reader :path

    def initialize(channel, id)
      @channel = channel
      @ship    = channel.ship
      @id      = id
      @action  = 'subscribe'
      @app     = 'graph-store'
      @path    = '/updates'
    end

    def request_body
      [{
        action: action,
        app:    app,
        id:     id,
        path:   path,
        ship:   ship.untilded_name
      }].to_json
    end
  end
end
