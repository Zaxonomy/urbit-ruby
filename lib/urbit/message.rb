require 'json'

module Urbit
  class Message
    attr_reader :action, :app, :channel, :id, :json, :mark, :ship

    def initialize(channel, id, action, app, mark, json)
      @channel = channel
      @id      = id
      @ship    = channel.ship
      @action  = action
      @app     = app
      @mark    = mark
      @json    = json
    end

    def transmit
      response = Faraday.put(channel_url) do |req|
        req.headers['Cookie'] = self.ship.cookie
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
      end

      # TODO
      # handle_error if response.status != 204

      response.reason_phrase
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

    def channel_url
      "#{self.ship.config.api_base_url}/~/channel/#{self.channel.key}"
    end
  end

  class CloseMessage < Message
    def initialize(channel, id)
      @channel = channel
      @ship = channel.ship
      @id      = id
      @action  = 'delete'
      end
    end

    class SubscribeMessage < Message
      def initialize(channel, id)
        @channel = channel
        @ship    = channel.ship.name
        @id      = id
        @action  = 'subscribe'
        @app     = 'chat-view'
        @path    = '/primary'
    end

    def request_body
      [{
        action: action,
        id: id
      }].to_json
    end
  end
end
