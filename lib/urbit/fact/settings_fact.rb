# frozen_string_literal: true

module Urbit
  module Fact
    class SettingsEventFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event

        if self.for_this_ship?
          # See if we already have this setting, if no add it, if yes update it.
          if (entries = channel.ship.settings[desk: self.desk].entries(bucket: self.bucket))
            entries[self.entry] = self.value
          end
        end
      end

      def bucket
        self.contents["bucket-key"]
      end

      def contents
        JSON.parse(@data)["json"]["settings-event"]["put-entry"]
      end

      def desk
        self.contents["desk"]
      end

      def entry
        self.contents["entry-key"]
      end

      def to_h
        super.merge!({
          bucket: self.bucket,
          desk:   self.desk,
          entry:  self.entry,
          value:  self.value
        })
      end

      def value
        self.contents["value"]
      end
    end
  end
end
