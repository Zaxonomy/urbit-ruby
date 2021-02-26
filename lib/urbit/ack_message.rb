require 'json'

require 'urbit/message'

module Urbit
  class AckMessage < Message
    def initialize(channel, sse_message_id)
      @action  = 'ack'
      @channel = channel
      @id      = 0
      @ack_id  = sse_message_id
    end

    def to_h
      {'id' => id, 'action' => action, 'event-id' => @ack_id}
    end
  end
end
