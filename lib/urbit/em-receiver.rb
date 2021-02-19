require 'em-eventsource'

module Urbit
  class Receiver < EventMachine::EventSource
    attr_accessor :events

    def initialize(ship, uri)
      @events = []
      @headers = {'Cookie' => ship.cookie}
      super(uri, {}, @headers)
    end

  end
end

# const eventSource = new EventSource('http://localhost:8080/~/channel/1601844290-ae45b', {
#   withCredentials: true // Required, sends your cookie
# });
#
# eventSource.addEventListener('message', function (event) {
#   ack(Number(event.lastEventId)); // See section below
#   const payload = JSON.parse(event.data); // Data is sent in JSON format
#   payload.id === event.lastEventId; // The SSE spec includes event IDs. This information is duplicated in the payload.
#   const data = payload.json; // Beyond this, the actual data will vary between apps
# });
#
# eventSource.addEventListener('error', function (event) {
#   handleError(event);
# });
