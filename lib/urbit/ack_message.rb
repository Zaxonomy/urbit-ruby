module Urbit
  class AckMessage < Message
    attr_reader :ack_id

    def initialize(channel, sse_message_id)
      super(channel, 'ack')
      @ack_id  = sse_message_id
    end

    def to_h
      # Need to use the older hash style due to the key having a dash.
      {'id' => self.id, 'action' => self.action, 'event-id' => self.ack_id}
    end

    def to_s
      "#{self.to_h}"
    end
  end
end
