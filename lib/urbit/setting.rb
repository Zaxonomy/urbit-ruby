
module Urbit
  class Setting
     attr_reader :desk

    def initialize(desk:, buckets:)
      @desk    = desk
      @buckets = buckets  # buckets is a hash of bucket_name and an entries hash.
      @entries = {}
    end

    def ==(another_group)
      another_setting.desk == self.desk
    end

    def <=>(another_group)
      self.desk <=> another_group.desk
    end

    def buckets
      @buckets
    end

    def entries(bucket:)
      if @entries.empty?
        @buckets.each {|k, v| @entries[k] = v}
      end
      @entries[bucket]
    end

    def to_h
      {
        desk:    @desk,
        buckets: self.buckets,
        # entries: self.entries
      }
    end

    def to_s
      "a Setting(#{self.to_h})"
    end
  end
end
