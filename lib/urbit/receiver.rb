require 'ld-eventsource'

require 'urbit/ack_message'
require 'urbit/fact'

module Urbit
  class Receiver < SSE::Client
    attr_accessor :facts

    def initialize(channel)
      @facts = []
      super(channel.url, {headers: self.headers(channel)}) do |rec|
        # We are now listening on a socket for SSE::Events. This block will be called for each one.
        rec.on_event do |event|
          # Wrap the returned event in a Fact.
          @facts << (f = Fact.new channel, event)

          # We need to acknowlege each message or urbit will eventually disconnect us.
          # We record the ack with the Fact itself.
          f.add_ack (ack = AckMessage.new(channel, event.id))
          channel.send_message(ack)
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

    private

    def headers(channel)
      {
        "Accept"        => "text/event-stream",
        "Cache-Control" => "no-cache",
        'Cookie'        => channel.ship.cookie,
        "Connection"    => "keep-alive",
        "User-Agent"    => "urbit-ruby"
      }
    end
  end
end
