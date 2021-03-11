module Urbit
  class CloseMessage < Message
    def initialize(channel)
      @action  = 'delete'
      @channel = channel
      @id      = 0
    end

    def to_h
      {id: id, action: action}
    end
  end
end
