module Urbit
  class PokeMessage < Message
    def initialize(channel:, app:, mark:, a_string:)
      super(channel: channel, app: app, mark: mark, contents: a_string)
    end
  end
end
