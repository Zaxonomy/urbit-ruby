require 'ld-eventsource'
require 'urbit/ack_message'

module Urbit
  class Receiver < SSE::Client
    attr_accessor :events

    def initialize(channel)
      @events = []
      @headers = {'cookie' => channel.ship.cookie}
      super(channel.url, {headers: @headers}) do |rec|
        rec.on_event do |event|
          typ = event.type
          dat = JSON.parse(event.data)
          self.events << {typ => dat}
          m = AckMessage.new(channel, event.id)
          m.transmit
          channel.messages << m
        end

        rec.on_error do |error|
          self.events += ["I received an error: #{error.class}"]
        end
      end
    end

  end
end
