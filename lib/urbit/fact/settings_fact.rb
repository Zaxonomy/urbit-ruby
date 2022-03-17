# frozen_string_literal: true

module Urbit
  module Fact

    class SettingsEventFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.accept if self.for_this_ship?
      end

      def bucket
        self.contents["bucket-key"]
      end

      def desk
        self.contents["desk"]
      end

      def to_h
        super.merge!({
          bucket: self.bucket,
          desk:   self.desk,
        })
      end
    end

    class SettingsEventPutBucketFact < SettingsEventFact
      def accept
        # This is a new bucket, add it.
        s = channel.ship.settings[desk: self.desk]
        s.buckets << Bucket.new(setting: s, name: self.bucket, entries: self.entries)
        nil
      end

      def contents
        JSON.parse(@data)["json"]["settings-event"]["put-bucket"]
      end

      def entries
        self.contents["bucket"]
      end

      def to_h
        super.merge!({
          entries: self.entries
        })
      end
    end

    class SettingsEventPutEntryFact < SettingsEventFact
      def accept
        # See if we already have this setting, if no add it, if yes update it.
        if (entries = channel.ship.settings[desk: self.desk].entries(bucket: self.bucket))
          entries[self.entry] = self.value
        end
      end

      def contents
        JSON.parse(@data)["json"]["settings-event"]["put-entry"]
      end

      def entry
        self.contents["entry-key"]
      end

      def to_h
        super.merge!({
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
