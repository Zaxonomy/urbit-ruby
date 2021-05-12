module Urbit
  class Node
    attr_reader :index, :post

    def initialize(index, node_json)
      @index = index.delete_prefix('/')
      data = node_json['post']
      @contents   = data['contents']
      @time_sent  = data['time-sent']
    end

    def to_s
      "a Node(#{@index}) => {time_sent: #{@time_sent}, contents: #{@contents}}"
    end
  end
end
