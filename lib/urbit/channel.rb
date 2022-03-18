require 'securerandom'

require 'urbit/message'
require 'urbit/receiver'
require 'urbit/close_message'
require 'urbit/poke_message'
require 'urbit/subscribe_message'

module Urbit
  class Channel
    attr_accessor :messages
    attr_reader :key, :name, :receiver, :ship

    def initialize(ship:, name:)
      @ship          = ship
      @key           = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
      @messages      = []
      @name          = name
      @receiver      = nil
      @is_open       = false
    end

    def close
      m = Urbit::CloseMessage.new(channel: self)
      @is_open = !self.send(message: m)
    end

    def closed?
      !@is_open
    end

    def open?
      @is_open
    end

    #
    # Poke an app with a message using a mark.
    # The message must be a Ruby Hash, not a String.
    #
    def poke(app:, mark:, message:)
      @is_open = self.send(message: (Urbit::PokeMessage.new(channel: self, app: app, mark: mark, a_message_hash: message)))
      @receiver = Urbit::Receiver.new(channel: self)
      self
    end

    def queue(message:)
      message.id = self.sent_messages.size + 1
      @messages << message
    end

    # Answers true if message was successfully sent.
    def send(message:)
      self.queue(message: message)
      resp = message.transmit
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
    def subscribe(app:, path:)
      m = Urbit::SubscribeMessage.new(channel: self, app: app, path: path)
      @is_open = self.send(message: m)
      @receiver = Urbit::Receiver.new(channel: self)
      self
    end

    def subscribed?
      @is_open
    end

    def to_s
      "a Channel (#{self.status}) on #{self.ship.name}(name: '#{self.name}', key: '#{self.key}')"
    end

    def url
      "#{self.ship.url}/~/channel/#{self.key}"
    end
  end
end
