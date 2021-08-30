module Urbit
  class Node
    def initialize(graph:, node_json:)
      @graph      = graph
      @post_h     = node_json['post']
      @children_h = node_json['children']
      @persistent = false
      @index      = nil
    end

    def ==(another_node)
      another_node.raw_index == self.raw_index
    end

    def <=>(another_node)
      self.time_sent <=> another_node.time_sent
    end

    def eql?(another_node)
      another_node.raw_index == self.raw_index
    end

    def hash
      self.raw_index.hash
    end

    def author
      @post_h["author"]
    end

    def children
      @children = []
      if @children_h
        @children_h.each do |k, v|
          @children << Urbit::Node.new(graph: @graph, node_json: v)
        end
      end
      @children
    end

    def contents
      @post_h['contents']
    end

    def persistent?
      @persistent
    end

    #
    # Answers the memoized @index or calculates it from the raw_index.
    #
    def index
      return @index if @index
      @index = self.index_to_atom
    end

    #
    # Answers the next {count} Nodes relative to this Node.
    # Defaults to the next Node if no {count} is passed.
    #
    def next(count: 1)
      @graph.newer_sibling_nodes(node: self, count: count)
    end

    #
    # Answers the previous {count} Nodes relative to this Node.
    # Defaults to the next Node if no {count} is passed.
    #
    def previous(count: 1)
      @graph.older_sibling_nodes(node: self, count: count)
    end

    def raw_index
      @post_h["index"].delete_prefix('/')
    end

    def time_sent
      @post_h['time-sent']
    end

    def to_h
      {
        index: self.index,
        author: self.author,
        contents: self.contents,
        time_sent: self.time_sent,
        is_parent: !self.children.empty?,
        child_count: self.children.count
      }
    end

    def to_s
      "a Node(#{self.to_h})"
    end

    private

    def index_to_atom
      subkeys = self.raw_index.split("/")
      subatoms = []
      subkeys.each do |s|
        subatoms << s.reverse.scan(/.{1,3}/).join('.').reverse
      end
      subatoms.join('/')
    end
  end
end
