require 'faraday'
require 'SecureRandom'

module Urbit
  module Api

    class Channel
      def initialize(ship, name)
        @ship      = ship
        @key       = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
        @messages  = []
        @name      = name
        @is_open   = false
      end

      def close
        # puts "closing #{name}"
        @messages << (m = CloseMessage.new self, self.next_id)
        @is_open = (r = m.transmit) != "ok"
        r
      end

      def closed?
        !@is_open
      end

      def key
        @key
      end

      def name
        @name
      end

      def next_id
        self.sent_messages.size + 1
      end

      def open?
        @is_open
      end

      def send_message(a_message_string)
        @messages << (m = Message.new  self, self.next_id, "poke", "hood", "helm-hi", a_message_string)
        @is_open = (r = m.transmit) == "ok"
        r
      end

      def sent_messages
        @messages
      end

      def ship
        @ship
      end

    end

  end
end
