# frozen_string_literal: true

module Urbit
  class GroupManager
    attr_accessor :groups, :ship

    def initialize(ship:)
      @ship   = ship
      @groups = []
    end

    #
    # Adds a Group to this Manager's groups collection
    #
    def add(a_group)
      @groups << a_group
    end

    def add_members(group_path:, ships:)
      if (group = self.find(path: group_path))
        group.members += ships
      end
    end

    def add_tag(group_path:, ships:, tag:)
      if (group = self.find(path: group_path))
        if (group.tags.include? tag)
          group.tags[tag] += ships
        end
      end
    end

    def create(name:, title:, description:)
      self.spider('group-create', %Q({"create": {"name": "#{name}", "title": "#{title}", "description": "#{description}", "policy": {"open": {"banRanks": [], "banned": []}}}}))
    end

    def empty?
      self.groups.empty?
    end

    #
    # Answers the Group uniquely keyed by path:, if it exists
    #
    def find(path:)
      g = self.groups.select {|g| g.path == path}.first
      g.manager = self
      g
    end

    def first
      g = self.groups.first
      g.manager = self
      g
    end

    def join(host:, name:, share_contact: false, auto_join: false)
      data = {join: {resource: {ship: "#{host}", name: "#{name}"}, ship: "#{host}", shareContact: share_contact, app: "groups", autojoin: auto_join}}
      self.ship.poke(app: 'group-view', mark: 'group-view-action', message: data)
      nil
    end

    def list
      self.groups
    end

    def remove_members(group_path:, ships:)
      if (group = self.find(path: group_path))
        group.members -= ships
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
      self.list.sort.each {|g| puts g}
    end

    private

    def remove(group)
      @groups = self.groups.filter {|g| g != group}
    end
  end
end