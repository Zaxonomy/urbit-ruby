module Urbit
  class PokeMessage < Message
    def initialize(channel:, app:, mark:, a_string:)
      super(channel: channel, action: 'poke', app: app, mark: mark, json: a_string)
    end
  end
end
