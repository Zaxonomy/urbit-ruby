module Urbit
  class Node
    attr_reader :index, :post, :time_sent

    def initialize(index, node_json)
      @index      = index.delete_prefix('/')
      @data       = node_json['post']
      @persistent = false
    end

    def ==(another_node)
      another_node.index == @index
    end

    def <=>(another_node)
      self.time_sent <=> another_node.time_sent
    end

    def contents
      @data['contents']
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
      @data['time-sent']
    end

    def to_atom
      @index.reverse.scan(/.{1,3}/).join('.').reverse
    end

    def to_s
      "a Node(#{@index})"
    end
  end
end
