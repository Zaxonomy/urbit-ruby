
module Urbit
  class Bucket
    attr_accessor :entries, :name

    def initialize(name:, entries:)
      @name = name
      @entries = Hash.new.replace(entries)
    end

    def [](key:)
      self.entries[key]
    end

    def to_h
      {name: @name, entries: @entries}
    end

    def to_s
      "a Bucket(#{self.to_h})"
    end

    def to_string
      "#{self.name}: #{self.entries.count} entries"
    end

  end
end
