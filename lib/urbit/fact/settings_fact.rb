# frozen_string_literal: true

module Urbit
  module Fact

    class SettingsEventFact < BaseFact
      def initialize(channel:, event:)
        super channel: channel, event: event
        self.accept if self.for_this_ship?
      end

      def accept
        nil
      end

      def base_contents
        JSON.parse(@data)["json"]["settings-event"]
      end

      def bucket
        self.desk[bucket: self.bucket_key]
      end

      def bucket_key
        self.contents["bucket-key"]
      end

      def desk
        self.ship.settings[desk: self.desk_name]
      end

      def desk_name
        self.contents["desk"]
      end

      def to_h
        super.merge!({
          bucket: self.bucket_key,
          desk:   self.desk_name,
        })
      end
    end

    class SettingsEventDelBucketFact < SettingsEventFact
      def accept
        self.desk.buckets.delete(self.bucket)
      end

      def contents
        self.base_contents["del-bucket"]
      end
    end

    class SettingsEventDelEntryFact < SettingsEventFact
      def accept
        self.bucket.entries.delete(self.entry)
      end

      def contents
        self.base_contents["del-entry"]
      end

      def entry
        self.contents["entry-key"]
      end
    end

    class SettingsEventPutBucketFact < SettingsEventFact
      def accept
        # This is a new bucket, add it.
        s = channel.ship.settings[desk: self.desk_name]
        s.buckets << Bucket.new(setting: s, name: self.bucket_key, entries: self.entries)
        nil
      end

      def contents
        self.base_contents["put-bucket"]
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
        if (entries = channel.ship.settings[desk: self.desk_name].entries(bucket: self.bucket_key))
          entries[self.entry] = self.value
        end
      end

      def contents
        self.base_contents["put-entry"]
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
