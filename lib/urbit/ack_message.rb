require 'json'
require 'urbit/message'

module Urbit
  class AckMessage < Message
    def initialize(channel, sse_message_id)
      @action  = 'ack'
      @channel = channel
      @id      = channel.next_id
      @ack_id  = sse_message_id
    end

    def request_body
      [{
        'id'       => id,
        'action'   => action,
        'event-id' => @ack_id
      }].to_json
    end
  end
end
