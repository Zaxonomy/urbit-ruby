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

    def empty?
      self.groups.empty?
    end

    #
    # Answers the Group uniquely keyed by path:, if it exists
    #
    def find_by_path(group_path)
      self.groups.select {|g| g.path == group_path}.first
    end

    def join(host:, name:, share_contact: false, auto_join: false)
      poke_msg = {join: {resource: {ship: "#{host}", name: "#{name}"}, ship: "#{host}", shareContact: share_contact, app: "groups", autojoin: auto_join}}
      self.ship.poke(app: 'group-view', mark: 'group-view-action', message: poke_msg)
      nil
    end

    def leave(group:)
      leave_json = %Q({"leave": {"ship": "#{group.host}", "name": "#{group.key}"}})
      self.ship.spider(mark_in: 'group-view-action', mark_out: 'json', thread: 'group-leave', data: leave_json)
      @groups = self.groups.filter {|g| g != group}
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
  end
end