
module Urbit
  class Bucket
    attr_accessor :entries, :name

    def initialize(setting:, name:, entries:)
      @setting = setting
      @name = name
      @entries = Hash.new.replace(entries)
    end

    def [](key:)
      self.entries[key]
    end

    def []=(key, val)
      msg = {"put-entry": {"desk": "#{@setting.desk}", "bucket-key": "#{self.name}", "entry-key": "#{key[:key]}", "value": val}}
      @setting.ship.poke(app: 'settings-store', mark: 'settings-event', message: msg)
      nil
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
