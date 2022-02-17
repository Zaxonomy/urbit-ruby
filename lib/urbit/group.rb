# frozen_string_literal: true

module Urbit
  class Group
     attr_accessor :manager, :members
     attr_reader :hidden, :path

    def initialize(path:, members:, policy:, tags:, hidden:)
      @hidden  = hidden
      @manager = nil
      @members = Set.new(members)
      @path    = path
      @policy  = policy
      @tags    = tags
    end

    def ==(another_group)
      another_group.path == self.path
    end

    def <=>(another_group)
      self.path <=> another_group.path
    end

    #
    # This is the action labeled as "Archive" in the Landscape UI.
    #
    def delete
      spdr = self.manager.spider('group-delete', %Q({"remove": {"ship": "#{self.host}", "name": "#{self.key}"}}))
      self.manager.remove(self) if 200 == spdr[:status]
      spdr
    end

    def eql?(another_group)
      another_group.path == self.path
    end

    def host
      self.path_tokens[0]
    end

    def invite(ship_names:, message:)
      data = %Q({
        "invite": {
          "resource": {
            "ship": "#{self.host}",
            "name": "#{self.key}"
          },
          "ships": [
            "#{ship_names.join(',')}"
          ],
          "description": "#{message}"
        }
      })
      self.manager.spider('group-invite', data)
    end

    def key
      self.path_tokens[1]
    end

    def leave
      spdr = self.manager.spider('group-leave', %Q({"leave": {"ship": "#{self.host}", "name": "#{self.key}"}}))
      self.manager.remove(self) if 200 == spdr[:status]
      spdr
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
      "a Group(#{self.path})"
    end
  end
end
