require 'faraday'

module Urbit
  class Message
    attr_accessor :id
    attr_reader :app, :channel, :contents, :mark

    def initialize(channel:, app: nil, mark: nil, contents: nil)
      @app      = app
      @channel  = channel
      @contents = contents
      @id       = 0
      @mark     = mark
    end

    #
    # The value for "action" that the inbound API expects for this message type.
    # defaults to "poke" for historical reasons, but each subclass should override appropriately.
    #
    def action
      "poke"
    end

    def channel_url
      "#{self.ship.url}/~/channel/#{self.channel.key}"
    end

    def request_body
      JSON.generate(self.to_a)
    end

    def ship
      self.channel.ship
    end

    def to_a
      [self.to_h]
    end

    def to_h
      {
        action: self.action,
        app:    app,
        id:     id,
        json:   contents,
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
      end

      # TODO: handle_error if response.status != 204
      response
    end
  end
end
