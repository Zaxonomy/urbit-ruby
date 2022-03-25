# frozen_string_literal: true

module Urbit
  class Groups < Set
    attr_accessor :ship

    def initialize(ship:)
      @ship   = ship
      @hash = {}
    end

    def [](path:)
      if (g = self.select {|g| g.path == path}.first)
        g.manager = self
        g
      end
    end

    #
    # Adds a Group to this Manager's groups collection
    #
    def add(a_group)
      a_group.manager = self
      self << a_group
    end

    def add_members(group_path:, ships:)
      if (group = self[path: group_path])
        group.members += ships
      end
    end

    def add_tag(group_path:, ships:, tag:)
      if (group = self[path: group_path])
        if (group.tags.include? tag)
          group.tags[tag] += ships
        end
      end
    end

    def create(name:, title:, description:)
      self.spider('group-create', %Q({"create": {"name": "#{name}", "title": "#{title}", "description": "#{description}", "policy": {"open": {"banRanks": [], "banned": []}}}}))
    end

    def empty?
      self.empty?
    end

    def join(host:, name:, share_contact: false, auto_join: false)
      data = {join: {resource: {ship: "#{host}", name: "#{name}"}, ship: "#{host}", shareContact: share_contact, app: "groups", autojoin: auto_join}}
      self.ship.poke(app: 'group-view', mark: 'group-view-action', message: data)
      nil
    end

    def list
      self.map {|g| g.path}.join("\n")
    end

    def remove(group)
      self.delete(group)
    end

    def remove_members(group_path:, ships:)
      if (group = self[path: group_path])
        group.members -= ships
      end
    end

    def remove_tag(group_path:, ships:, tag:)
      if (group = self[path: group_path])
        if (group.tags.include? tag)
          group.tags[tag] -= ships
        end
      end
    end

    def load
      if self.ship.logged_in?
        self.ship.subscribe(app: 'group-store', path: '/groups')
      end
      nil
    end

    def spider(thread, data)
      self.ship.spider(mark_in: 'group-view-action', mark_out: 'json', thread: thread, data: data)
    end

    def to_s
      self.sort.each {|g| puts g}
    end
  end
end