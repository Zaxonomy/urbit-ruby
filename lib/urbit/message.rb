require 'json'

module Urbit
  module Api

    class Message
      def initialize(channel, id, action, app, mark, json)
        @channel = channel
        @id      = id
        @ship    = channel.ship.name
        @action  = action
        @app     = app
        @mark    = mark
        @json    = json
      end

      def attributes
        instance_variables.reject {|var| :@channel == var }
      end

      def channel
        @channel
      end

      def id
        @id
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
    end

  end
end

# curl --header "Content-Type: application/json"
#      --cookie "urbauth-~zod=0v3.okvjc.4segg.g1mh8.32pkn.silsv"
#      --request PUT
#       --data '[{"id":1,"action":"poke","ship":"zod","app":"hood","mark":"helm-hi","json":"Opening airlock"}]'
#   http://localhost:8080/~/channel/1601844290-ae45b

# @response_headers={"date"=>"Tue, 26 Jan 2021 22:28:00 GMT",
# "connection"=>"keep-alive",
# "server"=>"urbit/vere-1.0",
# "set-cookie"=>"urbauth-~zod=0v4.bbb64.ttfql.sn6cf.oobo4.g4m7h; Path=/;
# Max-Age=604800"}
# @status=204
# @reason_phrase="ok"
# @response_body="">>@status=204 @reason_phrase="ok" @response_body="">>
