module Urbit
  class Node
    def initialize(a_graph, node_json)
      @graph      = a_graph
      @post_h     = node_json['post']
      @children_h = node_json['children']
      @persistent = false
    end

    def ==(another_node)
      another_node.index == self.index
    end

    def <=>(another_node)
      self.time_sent <=> another_node.time_sent
    end

    def author
      @post_h["author"]
    end

    def children
      @children = []
      if @children_h
        @children_h.each do |k, v|
          @children << Urbit::Node.new(@graph, v)
        end
      end
      @children
    end

    def contents
      @post_h['contents']
    end

    def eql?(another_node)
      another_node.index == self.index
    end

    def persistent?
      @persistent
    end

    def hash
      @index.hash
    end

    def index
      @post_h["index"].delete_prefix('/')
    end

    def time_sent
      @post_h['time-sent']
    end

    def to_atom
      subkeys = self.index.split("/")
      subatoms = []
      subkeys.each do |s|
        subatoms << s.reverse.scan(/.{1,3}/).join('.').reverse
      end
      subatoms.join('/')
    end

    def to_h
      {
        index: self.to_atom,
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
  end
end
