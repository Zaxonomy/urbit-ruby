require 'faraday'
require 'SecureRandom'

module Urbit
  module Api

    class Channel
      def initialize(name)
        @key = "#{Time.now.to_i}#{SecureRandom.hex(3)}"
        @messages = []
        @name = name
      end

      def key
        @key
      end

      def name
        @name
      end

      def pier
        "zod"
      end

      #(id, ship, action, app, mark, json)
      def send_message(a_message_string)
       m_id = self.sent_messages.size + 1
       m = Message.new  m_id, self.pier, "poke", "hood", "helm-hi", a_message_string
       m.transmit
      end

      def sent_messages
       @messages
      end
    end

  end
end
