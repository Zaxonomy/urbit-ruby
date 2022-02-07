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

    def leave(group_path)
      g = self.find_by_path(group_path)
      leave_json = %Q({"leave": {"ship": "#{g.host}", "name": "#{g.key}"}})
      self.ship.spider(mark_in: 'group-view-action', mark_out: 'json', thread: 'group-leave', data: leave_json)
      @groups = self.groups.filter {|g| g.path != group_path}
    end

    def load
      if self.ship.logged_in?
        self.ship.subscribe(app: 'group-store', path: '/groups')
      end
      nil
    end
  end
end