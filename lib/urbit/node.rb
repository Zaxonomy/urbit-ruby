module Urbit
  class Node
    attr_reader :contents, :index, :post, :time_sent

    def initialize(index, node_json)
      @index = index.delete_prefix('/')
      data = node_json['post']
      @contents   = data['contents']
      @time_sent  = data['time-sent']
    end

    def ==(another_node)
      another_node.index == @index
    end

    def eql?(another_node)
      another_node.index == @index
    end

    def hash
      @index.hash
    end

    # def <=>(another_node)
    #   return another_node.index <=> self.index
    # end

    def to_s
      "a Node(#{@index}) => {time_sent: #{@time_sent}, contents: #{@contents}}"
    end
  end
end
