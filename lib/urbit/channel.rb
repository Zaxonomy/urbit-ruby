require 'faraday'
require 'securerandom'

require 'urbit/message'
require 'urbit/receiver'
require 'urbit/close_message'
require 'urbit/poke_message'
require 'urbit/subscribe_message'

module Urbit
  class Channel
    attr_accessor :messages
    attr_reader :key, :name, :ship

    def initialize(ship, name)
      @ship          = ship
      @key           = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
      @messages      = []
      @name          = name
      @is_open       = false
      @is_subscribed = false
    end

    def close
      # puts "closing #{name}"
      m = Urbit::CloseMessage.new(self)
      @is_open = !self.send_message(m)
    end

    def closed?
      !@is_open
    end

    #
    # We open a channel by "poking" the urbit app 'hood' using the mark 'helm-hi'
    #
    def open(a_message_string)
      m = Urbit::PokeMessage.new(self, "hood", "helm-hi", a_message_string)
      @is_open = self.send_message(m)
    end

    def open?
      @is_open
    end

    def queue_message(a_message)
      a_message.id = self.sent_messages.size + 1
      @messages << a_message
    end

    # Answers true if message was successfully sent.
    def send_message(a_message)
      self.queue_message(a_message)
      resp = a_message.transmit
      resp.reason_phrase == "ok"
    end

    def sent_messages
      @messages
    end

    def status
      self.open? ? "Open" : "Closed"
    end

    def subscribe(app, path)
      m = Urbit::SubscribeMessage.new(self, app, path)
      @is_subscribed = self.send_message(m)
      receiver = Urbit::Receiver.new(self)
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
