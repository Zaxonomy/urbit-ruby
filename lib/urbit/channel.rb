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
    end

    def close
      # puts "closing #{name}"
      m = Urbit::CloseMessage.new(self)
      @is_open = !self.send_message(m)
    end

    def closed?
      !@is_open
    end

    def open?
      @is_open
    end

    #
    # One way to open a channel by "poking" an urbit app with a mark and a (json) message.
    # A typical example of this is poking the 'hood' app using the mark 'helm-hi' to start a DM chat.
    #
    def poke(app, mark, message)
      @is_open = self.send_message(Urbit::PokeMessage.new(self, app, mark, message))
      receiver = Urbit::Receiver.new(self)
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

    #
    # Subscribe to an app at a path.
    # Returns a Receiver which will begin to get back a stream of facts... which is a... Dictionary? Encyclopedia?
    #
    def subscribe(app, path)
      m = Urbit::SubscribeMessage.new(self, app, path)
      @is_open = self.send_message(m)
      receiver = Urbit::Receiver.new(self)
    end

    def subscribed?
      @is_open
    end

    def to_s
      "a Channel (#{self.status}) on #{self.ship.name}(name: '#{self.name}', key: '#{self.key}')"
    end

    def url
      "http://localhost:8080/~/channel/#{self.key}"
    end
  end
end
