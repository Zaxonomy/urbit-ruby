module Urbit
  class PokeMessage < Message
    def initialize(channel, app, mark, a_string)
      super(channel, 'poke', app, mark, a_string)
    end
  end
end
