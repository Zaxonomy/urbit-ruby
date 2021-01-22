require 'json'

module Urbit
  module Api

    class Message
      def initialize(id, ship, action, app, mark, json)
        @id     = id
        @ship   = ship
        @action = action
        @app    = app
        @mark   = mark
        @json   = json
      end

      def id
        @id
      end

      def as_hash
        instance_variables.each_with_object(Hash.new(0)) { |element, hash| hash["#{element}".delete("@").to_sym] = instance_variable_get(element) }
      end

      def as_json
        JSON.generate(self.as_hash)
      end
    end

  end
end

# curl --header "Content-Type: application/json"
#      --cookie "urbauth-~zod=0v3.okvjc.4segg.g1mh8.32pkn.silsv"
#      --request PUT
#       --data '[{"id":1,"action":"poke","ship":"zod","app":"hood","mark":"helm-hi","json":"Opening airlock"}]'
#   http://localhost:8080/~/channel/1601844290-ae45b