module Urbit
  class Node
    attr_reader :children, :index, :post, :time_sent

    def initialize(index, node_json)
      @index      = index.delete_prefix('/')
      @post       = node_json['post']
      @children_h = node_json['children']
      @persistent = false
    end

    def ==(another_node)
      another_node.index == @index
    end

    def <=>(another_node)
      self.time_sent <=> another_node.time_sent
    end

    def author
      @post["author"]
    end

    def children
      @children = []
      @children_h.each do |k, v|
        @children << Urbit::Node.new(k, v)
      end
      @children
    end

    def contents
      @post['contents']
    end

    def eql?(another_node)
      another_node.index == @index
    end

    def persistent?
      @persistent
    end

    def hash
      @index.hash
    end

    def time_sent
      @post['time-sent']
    end

    def to_atom
      subkeys = @index.split("/")
      subatoms = []
      subkeys.each do |s|
        subatoms << s.reverse.scan(/.{1,3}/).join('.').reverse
      end
      subatoms.join('/')
    end

    def to_s
      "a Node(#{@index})"
    end
  end
end
