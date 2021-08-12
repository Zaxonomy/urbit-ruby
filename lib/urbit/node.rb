module Urbit
  class Node
    attr_reader :contents, :index, :post, :time_sent

    def initialize(index, node_json)
      @index      = index.delete_prefix('/')
      data        = node_json['post']
      @contents   = data['contents']
      @time_sent  = data['time-sent']
      @persistent = false
    end

    def ==(another_node)
      another_node.index == @index
    end

    def <=>(another_node)
      @time_sent <=> another_node.time_sent
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

    def to_s
      "a Node(#{@index}) => {time_sent: #{@time_sent}, contents: #{@contents}}"
    end
  end
end
