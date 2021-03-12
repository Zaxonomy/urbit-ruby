module Urbit
  class CloseMessage < Message
    def initialize(channel)
      super(channel, 'delete')
    end

    def to_h
      {id: self.id, action: self.action}
    end
  end
end
