# frozen_string_literal: true

module Urbit
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
        @graph = self.ship.graph(resource: self.graph_resource)
      end
      @graph
    end

    def graph_links
      @chain.find_graph_links_for_group(path: self.group_path)
    end

    def graph_resource
      @data['resource'].sub('/ship/', '')
    end

    def group
      if @group.nil?
        @group = self.ship.groups[path: self.group_path]
      end
      @group
    end

    def group_path
      @data['group'].sub('/ship/', '')
    end

    def metadata
      @data['metadata']
    end

    def ship
      @chain.ship
    end

    def to_list
      @path
    end

    def type
      @data['app-name']
    end
  end
end
