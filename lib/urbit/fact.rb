module Urbit
  class Fact
    attr_reader :ack

    def initialize(channel, event)
      @channel = channel
      @data = event.data
      @type = event.type
    end

    def add_ack(an_ack)
      @ack = an_ack
    end

    def contents
      JSON.parse(@data)
    end

    def graph_update?
      !self.contents["json"].nil? && !self.contents["json"]["graph-update"].nil?
    end

    def is_acknowledged?
      !@ack.nil?
    end

    def resource
      return nil unless self.graph_update?
      r = self.contents["json"]["graph-update"]["add-nodes"]["resource"]
      "#{r["ship"]}/#{r["name"]}"
    end

    def ship
      @channel.ship
    end

    def to_h
      {
        ship:            self.ship.to_h,
        resource:        self.resource,
        acknowleged:     self.is_acknowledged?,
        is_graph_update: self.graph_update?
        # contents:        self.contents
      }
    end

    def to_s
      "a Fact(#{self.to_h})"
    end
  end
end
