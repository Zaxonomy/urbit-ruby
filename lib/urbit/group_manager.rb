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

    def create(name:, title:, description:)
      self.spider('group-create', %Q({"create": {"name": "#{name}", "title": "#{title}", "description": "#{description}", "policy": {"open": {"banRanks": [], "banned": []}}}}))
    end

    #
    # This is the action labeled as "Archive" in the Landscape UI.
    def delete(group:)
      spdr = self.spider('group-delete', %Q({"remove": {"ship": "#{group.host}", "name": "#{group.key}"}}))
      self.remove(group) if 200 == spdr[:status]
      nil
    end

    def empty?
      self.groups.empty?
    end

    #
    # Answers the Group uniquely keyed by path:, if it exists
    #
    def find(path:)
      self.groups.select {|g| g.path == group_path}.first
    end

    def first
      self.groups.first
    end

    def join(host:, name:, share_contact: false, auto_join: false)
      data = {join: {resource: {ship: "#{host}", name: "#{name}"}, ship: "#{host}", shareContact: share_contact, app: "groups", autojoin: auto_join}}
      self.ship.poke(app: 'group-view', mark: 'group-view-action', message: data)
      nil
    end

    def leave(group:)
      spdr = self.spider('group-leave', %Q({"leave": {"ship": "#{group.host}", "name": "#{group.key}"}}))
      self.remove(group) if 200 == spdr[:status]
      nil
    end

    def list
      self.groups
    end

    def load
      if self.ship.logged_in?
        self.ship.subscribe(app: 'group-store', path: '/groups')
      end
      nil
    end

    def to_s
      self.list.sort.each {|g| puts g}
    end

    private

    def remove(group)
      @groups = self.groups.filter {|g| g != group}
    end

    def spider(thread, data)
      self.ship.spider(mark_in: 'group-view-action', mark_out: 'json', thread: thread, data: data)
    end
  end
end