# frozen_string_literal: true

require 'urbit/parser'

module Urbit

  class GroupParser < Parser
    def resource
      "~#{self.resource_hash["ship"]}/#{self.resource_hash["name"]}"
    end

    def resource_hash
      @j["resource"]
    end
  end

  class AddGroupParser < GroupParser
    def group
      Urbit::Group.new(path:    self.resource,
                       members: [],
                       policy:  @j["policy"],
                       tags:    [],
                       hidden:  @j["hidden"])
    end
  end

  class ChangeMemberParser < GroupParser
    def ships
      @j["ships"]
    end
  end

  class InitialGroupParser < Parser
    def groups
      self.group_hashes.collect {|k, v| Group.new(path:    k.sub('/ship/', ''),
                                                  members: v["members"],
                                                  policy:  v["policy"],
                                                  tags:    v["tags"],
                                                  hidden:  v["hidden"])}
    end

    def group_hashes
      @j
    end
  end

  class InitialGroupGroupParser < GroupParser
    def group
      Urbit::Group.new(path:    self.resource,
                       members: self.group_hash["members"],
                       policy:  self.group_hash["policy"],
                       tags:    self.group_hash["tags"],
                       hidden:  self.group_hash["hidden"])
    end

    def group_hash
      @j["group"]
    end
  end

end
