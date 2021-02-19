require 'faraday'
require 'SecureRandom'

require 'urbit/message'
require 'urbit/ld-receiver'

module Urbit
  class Channel
    attr_accessor :messages
    attr_reader :key, :name, :ship

    def initialize(ship, name)
      @ship      = ship
      @key       = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
      @messages  = []
      @name      = name
      @is_open   = false
      @is_subscribed = false
    end

    def close
      # puts "closing #{name}"
      @messages << (m = CloseMessage.new self, self.next_id)
      @is_open = (r = m.transmit).reason_phrase != "ok"
      r.reason_phrase
    end

    def closed?
      !@is_open
    end

    def next_id
      self.sent_messages.size + 1
    end

    def open?
      @is_open
    end

    def send_message(a_message_string)
      @messages << (m = Message.new  self, self.next_id, "poke", "hood", "helm-hi", a_message_string)
      @is_open = (r = m.transmit).reason_phrase == "ok"
      r
    end

    def sent_messages
      @messages
    end

    def subscribe
      @messages << (m = SubscribeMessage.new self, self.next_id)
      @is_subscribed = (response = m.transmit).reason_phrase == "ok"

      receiver = Receiver.new(self)
      receiver

      # EM.run do
        # source = Receiver.new(self.ship, self.url)
        # source.message do |message|
        #   puts "I received an event: #{message}"
        # end
        # source.start # Start listening
      # end

      # source
    end

    def subscribed?
      @is_subscribed
    end

    def url
      "http://localhost:8080/~/channel/#{self.key}"
    end
  end
end

# const eventSource = new EventSource('http://localhost:8080/~/channel/1601844290-ae45b', {
#   withCredentials: true // Required, sends your cookie
# });
#
# eventSource.addEventListener('message', function (event) {
#   ack(Number(event.lastEventId)); // See section below
#   const payload = JSON.parse(event.data); // Data is sent in JSON format
#   payload.id === event.lastEventId; // The SSE spec includes event IDs. This information is duplicated in the payload.
#   const data = payload.json; // Beyond this, the actual data will vary between apps
# });
#
# eventSource.addEventListener('error', function (event) {
#   handleError(event);
# });
