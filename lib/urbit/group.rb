# frozen_string_literal: true

module Urbit
  class Group
     attr_reader :hidden, :members, :path

    def initialize(path:, json:)
      @hidden  = json["hidden"]
      @members = json["members"]
      @path    = path
      @policy  = json["policy"]
      @tags    = json["tags"]
    end

    def ==(another_group)
      another_group.path == self.path
    end

    def <=>(another_group)
      self.key <=> another_group.key
    end

    def eql?(another_group)
      another_group.path == self.path
    end

    def host
      self.path_tokens[2]
    end

    def key
      self.path_tokens[3]
    end

    def path_tokens
      self.path.split('/')
    end

    def pending_invites
      if (i = @policy["invite"])
        if (p = i["pending"])
          return p.count
        end
      end
      '?'
    end

    def to_h
    {
        host:            self.host,
        key:             self.key,
        member_count:    self.members.count,
        pending_invites: self.pending_invites,
        hidden:          self.hidden
      }
    end

    def to_s
      "a Group(#{self.to_h})"
    end
  end
end
