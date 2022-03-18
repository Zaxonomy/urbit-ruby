module Urbit
  class PokeMessage < Message
    def initialize(channel:, app:, mark:, a_message_hash:)
      super(channel: channel, app: app, mark: mark, contents: a_message_hash)
    end
  end
end
