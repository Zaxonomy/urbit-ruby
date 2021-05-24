require 'ld-eventsource'

require 'urbit/ack_message'

module Urbit
  class Receiver < SSE::Client
    attr_accessor :facts

    def initialize(channel)
      @facts = []
      @headers = {'cookie' => channel.ship.cookie}
      super(channel.url, {headers: @headers}) do |rec|
        rec.on_event do |event|
          typ = event.type
          dat = JSON.parse(event.data)
          self.facts << {typ => dat}
          channel.send_message(AckMessage.new(channel, event.id))
        end

        rec.on_error do |error|
          self.facts += ["I received an error fact: #{error.class}"]
        end
      end
      @is_open = true
    end

    def open?
      @is_open
    end
  end
end
