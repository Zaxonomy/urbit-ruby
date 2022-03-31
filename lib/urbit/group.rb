# frozen_string_literal: true

module Urbit
  class Group
     attr_accessor :graphs, :manager, :members, :tags
     attr_reader :hidden, :path, :policy

    def initialize(path:, members:, policy:, tags:, hidden:)
      @graphs  = Set.new
      @hidden  = hidden
      @manager = nil
      @members = Set.new(members)
      @path    = path
      @policy  = policy
      @tags    = self.parse_tags(tags)
    end

    def ==(another_group)
      another_group.path == self.path
    end

    def <=>(another_group)
      self.path <=> another_group.path
    end

    #
    # This is the action labeled as "Archive" in the Landscape UI.
    # As of now, you can only do this to groups on your own ship.
    #
    def delete
      if (self.host == self.manager.ship.name)
        spdr = self.manager.spider('group-delete', %Q({"remove": {"ship": "#{self.host}", "name": "#{self.key}"}}))
        self.manager.remove(self) if 200 == spdr[:status]
        return spdr
      end
      {status: 400, code: 'bad_request', body: 'Can only delete Groups on your own ship.'}
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
      "a Group(#{self.to_h})"
    end

    private

    def parse_tags(tags)
      h = {}
      return h if tags.empty?
      tags.each {|k, v| h[k] = Set.new(v)}
      tags.replace(h)
    end

  end
end
