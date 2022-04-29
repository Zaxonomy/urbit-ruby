# frozen_string_literal: true

module Urbit
  class Links < Set
    attr_reader :ship

    def initialize
      @hash = {}
      @ship = nil
    end

    def [](path:)
      self.select {|l| path == l.path}.first
    end

    def find_graph(resource:)
      self.select{|l| l.type == 'graph' && resource == l.graph_resource}.first
    end

    def find_graph_links_for_group(path:)
      self.select{|l| l.type == 'graph' && path == l.group_path}
    end

    def find_group(path:)
      self.select{|l| l.type == 'groups' && path == l.group_path}.first
    end

    def list
      self.sort.each {|l| puts l.to_list}
      nil
    end

    def load(ship:)
      ship.subscribe(app: 'metadata-store', path: '/all')
      @ship = ship
      nil
    end
  end
end
