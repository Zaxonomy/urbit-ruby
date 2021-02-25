require 'faraday'

require 'urbit/message'
require 'urbit/receiver'

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

    def status
      self.open? ? "Open" : "Closed"
    end

    def subscribe
      @messages << (m = SubscribeMessage.new self, self.next_id)
      @is_subscribed = (response = m.transmit).reason_phrase == "ok"
      receiver = Receiver.new(self)
    end

    def subscribed?
      @is_subscribed
    end

    def to_s
      "a Channel (#{self.status}) on #{self.ship.name}(name: '#{self.name}', key: '#{self.key}')"
    end

    def url
      "http://localhost:8080/~/channel/#{self.key}"
    end
  end
end
