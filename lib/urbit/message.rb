require 'json'

module Urbit
  module Api

    class Message
      attr_reader :channel, :id

      def initialize(channel, id, action, app, mark, json)
        @channel = channel
        @id      = id
        @ship    = channel.ship.name
        @action  = action
        @app     = app
        @mark    = mark
        @json    = json
      end

      def as_hash
        self.attributes.each_with_object(Hash.new(0)) { |element, hash| hash["#{element}".delete("@").to_sym] = instance_variable_get(element) }
      end

      def as_json
        JSON.generate(self.as_hash)
      end

      def ship
        @ship.name
      end

      def transmit
        response = Faraday.put("http://localhost:8080/~/channel/#{self.channel.key}") do |req|
          req.headers['Cookie'] = self.channel.ship.cookie
          req.headers['Content-Type'] = 'application/json'
          req.body = "[#{self.as_json}]"
        end
        response.reason_phrase
      end

      private

      def attributes
        instance_variables.reject {|var| :@channel == var }
      end

    end

    class CloseMessage < Message
      def initialize(channel, id)
        @channel = channel
        @id      = id
        @action  = 'delete'
      end
    end

  end
end
