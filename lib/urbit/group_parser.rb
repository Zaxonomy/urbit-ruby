# frozen_string_literal: true

require 'urbit/parser'

module Urbit
  class InitialGroupParser < Parser
    def groups
      self.group_hashes.collect {|k, v| Group.new(path: k.sub('/ship/', ''), json: v)}
    end

    def group_hashes
      @j
    end
  end

  class InitialGroupGroupParser < Parser
    def group
      Urbit::Group.new(path: self.resource, json: self.group_hash)
    end

    def group_hash
      @j["group"]
    end

    def resource
      "~#{self.resource_hash["ship"]}/#{self.resource_hash["name"]}"
    end

    def resource_hash
      @j["resource"]
    end
  end

end
