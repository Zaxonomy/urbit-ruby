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

    def findGraph(resource:)
      self.select{|l| l.type == 'graph' && resource == l.resource}.first
    end

    def findGroup(path:)
      self.select{|l| l.type == 'groups' && path == l.resource}.first
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

  class Link
    attr_reader :path, :data

    def initialize(chain:, path:, data:)
      @chain = chain
      @graph = nil
      @group = nil
      @path  = path
      @data  = data
    end

    def ==(another)
      another.path == self.path
    end

    def <=>(another)
      self.path <=> another.path
    end

    def eql?(another)
      another.path == self.path
    end

    def graph
      if @graph.nil?
        @graph = @chain.ship.graph(resource: self.resource)
        @graph.group = self.group
      end
      @graph
    end

    def group
      if @group.nil?
        @group = @chain.ship.groups[path: self.group_path]
        @group.graphs << self.graph
      end
      @group
    end

    def group_path
      @data['group'].sub('/ship/', '')
    end

    def metadata
      @data['metadata']
    end

    def resource
      @data['resource'].sub('/ship/', '')
    end

    def to_list
      @path
    end

    def type
      @data['app-name']
    end
  end
end
