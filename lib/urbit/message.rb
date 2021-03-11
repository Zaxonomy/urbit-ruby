require 'json'

module Urbit
  class Message
    attr_accessor :id
    attr_reader :action, :app, :channel, :json, :mark

    def initialize(channel, action, app, mark, json)
      @action  = action
      @app     = app
      @channel = channel
      @id      = 0
      @json    = json
      @mark    = mark
    end

    def channel_url
      "#{self.ship.config.api_base_url}/~/channel/#{self.channel.key}"
    end

    def request_body
      self.to_a.to_json
    end

    def ship
      self.channel.ship
    end

    def to_a
      [self.to_h]
    end

    def to_h
      {
        action: action,
        app:    app,
        id:     id,
        json:   json,
        mark:   mark,
        ship:   ship.untilded_name
      }
    end

    def to_s
      "a Message(#{self.to_h})"
    end

    def transmit
      response = Faraday.put(channel_url) do |req|
        req.headers['Cookie'] = self.ship.cookie
        req.headers['Content-Type'] = 'application/json'
        req.body = request_body
        # puts req.body.to_s
      end

      # TODO: handle_error if response.status != 204
      response
    end
  end
end
