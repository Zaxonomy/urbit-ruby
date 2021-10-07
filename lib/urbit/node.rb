require 'set'

module Urbit
  class Node
    attr_accessor :node_json
    def initialize(graph:, node_json:)
      @graph      = graph
      @post_h     = node_json['post']
      @children_h = node_json['children']
      @persistent = false
      @index      = nil
    end

    #
    # Given a bigint representing an urbit date, returns a unix timestamp.
    #
    def self.da_to_unix(da)
      # ported from urbit lib.ts which in turn was ported from +time:enjs:format in hoon.hoon
      da_second = 18446744073709551616
      da_unix_epoch = 170141184475152167957503069145530368000
      offset = da_second / 2000
      epoch_adjusted = offset + (da - da_unix_epoch)
      return (epoch_adjusted * 1000) / da_second
    end

    #
    # Given a unix timestamp, returns a bigint representing an urbit date
    #
    def self.unix_to_da(unix)
      da_second = 18446744073709551616
      da_unix_epoch = 170141184475152167957503069145530368000
      time_since_epoch =  (unix * da_second) / 1000
      return da_unix_epoch + time_since_epoch;
    end

    def ==(another_node)
      another_node.index == self.index
    end

    def <=>(another_node)
      self.time_sent <=> another_node.time_sent
    end

    def eql?(another_node)
      another_node.index == self.index
    end

    def deleted?
      # This is a "deleted" node. Not sure what to do yet, but for now don't create a Node.
      @post_h["index"].nil?
    end

    def hash
      self.index.hash
    end

    def author
      @post_h["author"]
    end

    def children
      @children = SortedSet.new
      if @children_h
        @children_h.each do |k, v|
          @children << (n = Urbit::Node.new(graph: @graph, node_json: v))
          # Recursively fetch all the children's children until we reach the bottom...
          n.children.each {|c| @children << c} if !n.children.empty?
        end
      end
      @children
    end

    def contents
      @post_h['contents']
    end

    def datetime_sent
      Time.at(self.time_sent / 1000).to_datetime
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
      return @post_h["index"].delete_prefix('/') unless self.deleted?
      (Node.unix_to_da(Time.now.to_i)).to_s
    end

    #
    # This is the time sent as recorded by urbit in unix extended format.
    #
    def time_sent
      @post_h['time-sent']
    end

    def to_h
      {
        index: self.index,
        author: self.author,
        sent: self.datetime_sent,
        contents: self.contents,
        is_parent: !self.children.empty?,
        child_count: self.children.count
      }
    end

    def to_pretty_array
      self.to_h.each.map {|k, v| "#{k}#{(' ' * (12 - k.length))}#{v}"}
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
