require 'set'
require 'urbit/node'
require 'urbit/parser'

module Urbit
  class Graph
    attr_reader   :host_ship_name, :name, :ship

    def initialize(ship:, graph_name:, host_ship_name:)
      @ship           = ship
      @group          = nil
      @host_ship_name = host_ship_name
      @name           = graph_name
      @nodes          = SortedSet.new
    end

    def add_node(node:)
      @nodes << node unless node.deleted?
    end

    def creator
      self.fetch_link if @creator.nil?
      @creator
    end

    def delete
      resp = self.ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-delete', data: self.delete_graph_json, args: ["NO_RESPONSE"])
      @persistent = !(200 == resp[:status])
    end

    def description
      self.fetch_link if @description.nil?
      @description
    end

    def group
      if @group.nil?
        @link = self.fetch_link
        @group = @link.group unless @link.nil?
      end
      @group
    end

    def group=(a_group)
      @group = a_group
    end

    def host_ship
      "~#{@host_ship_name}"
    end

    #
    # This method doesn't have a json mark and thus is not (yet) callable from the Airlock.
    # Answers a %noun in `(unit mark)` format.
    #
    # def mark
    #   r = self.ship.scry(app: 'graph-store', path: "/graph/#{self.to_s}/mark")
    # end

    #
    # Transform this Graph into a PublishGraph.
    #
    # TODO: This is a very crude way to do this since we don't get the type of graph back from
    #       our initial call to retrieve the graphs, only later with the metadata.
    #
    #       This will need some more thought.
    #
    def molt
      return PublishGraph.new(ship: self.ship, graph_name: self.name, title: self.title, description: self.description, persistent: true) if 'publish' == self.type
      self
    end

    #
    # Finds a single node in this graph by its index.
    # The index here should be the atom representation (as returned by Node#index).
    #
    def node(index:)
      self.fetch_node(index).first
    end

    #
    # Answers an array with all of this Graph's currently attached Nodes, recursively
    # inluding all of the Node's children.
    #
    def nodes
      self.fetch_all_nodes if @nodes.empty?
      @all_n = []
      @nodes.each do |n|
        @all_n << n
        n.children.each do |c|
          @all_n << c
        end
      end
      @all_n
    end

    def newest_nodes(count: 10)
      count = 1 if count < 1
      return self.fetch_newest_nodes(count) if @nodes.empty? || @nodes.count < count
      last_node = self.nodes.count - 1
      self.nodes[(last_node - count)..last_node]
    end

    def oldest_nodes(count: 10)
      count = 1 if count < 1
      return self.fetch_oldest_nodes(count) if @nodes.empty? || @nodes.count < count
      self.nodes[0..(count - 1)]
    end

    def resource
      "#{self.host_ship}/#{self.name}"
    end

    #
    # Answers the {count} newer sibling nodes relative to the passed {node}.
    #
    def newer_sibling_nodes(node:, count:)
      self.fetch_sibling_nodes(node, :newer, count)[0..(count - 1)]
    end

    #
    # Answers the {count} older sibling nodes relative to the passed {node}.
    #
    def older_sibling_nodes(node:, count:)
      self.fetch_sibling_nodes(node, :older, count)[0..(count - 1)]
    end

    def title
      self.fetch_link if @title.nil?
      @title
    end

    def type
      self.fetch_link if @type.nil?
      @type
    end

    #
    # the canonical printed representation of a Graph
    def to_s
      "a #{self.class.name.split('::').last}(#{self.resource})"
    end

    private

    def delete_graph_json
      %Q({"delete": {"resource": {"ship": "#{self.ship.name}", "name": "#{self.name}"}}})
    end

    def fetch_all_nodes
      self.fetch_nodes("#{self.graph_resource}/", AddGraphParser, "add-graph")
    end

    def fetch_link
      @link  = self.ship.links.find_graph(resource: self.resource)
      @creator     = @link.metadata['creator']
      @description = @link.metadata['description']
      @title       = @link.metadata['title']
      @type        = @link.metadata['config']['graph']
      @link
    end

    def fetch_newest_nodes(count)
      self.fetch_nodes("#{self.graph_resource}/node/siblings/newest/kith/#{count}/",
                       AddNodesParser,
                       "add-nodes")
    end

    def fetch_node(index_atom)
      self.fetch_nodes("#{self.graph_resource}/node/index/kith/#{index_atom}/",
                       AddNodesParser,
                       "add-nodes")
    end

    def fetch_oldest_nodes(count)
      self.fetch_nodes("#{self.graph_resource}/node/siblings/oldest/kith/#{count}/",
                       AddNodesParser,
                       "add-nodes")
    end

    def fetch_sibling_nodes(node, direction, count)
      self.fetch_nodes("#{self.graph_resource}/node/siblings/#{direction}/kith/#{count}/#{node.index}/",
                       AddNodesParser,
                       "add-nodes")
    end

    #
    # Answers an array of Nodes that were fetched or an empty array if nothing found.
    #
    def fetch_nodes(endpoint, parser, node)
      r = self.ship.scry(app: 'graph-store', path: endpoint)
      if (200 == r[:status])
        body = JSON.parse(r[:body])
        if (p = parser.new(for_graph: self, with_json: body["graph-update"][node]))
          return p.add_nodes
        end
      end
      []
    end

    def graph_resource
      "/graph/#{self.resource}"
    end
  end

  class PublishGraph < Graph

    attr_accessor :description, :title

    def initialize(ship:, graph_name:, title:, description:, persistent: false)
      super ship: ship, graph_name: graph_name, host_ship_name: ship.untilded_name
      @persistent = persistent
      @title = title
      @description = description
    end

    def add_post(author:, title:, body:)
      j = self.create_post_json(author, title, body)
      resp = self.ship.spider(mark_in: 'graph-update-3', mark_out: 'graph-view-action', thread: 'graph-add-nodes', data: j)
      (200 == resp[:status])
    end

    def persist
      # PublishGraph, persist thyself in urbit...
      resp = self.ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-create', data: self.create_graph_json)
      @persistent = (200 == resp[:status])
    end

    def persistent?
      @persistent
    end

    private

    def create_graph_json
      %Q({"create": {"resource"   : {"ship": "#{self.ship.name}", "name": "#{self.name}"},
                     "title"      : "#{self.title}",
                     "description": "#{self.description}",
                     "associated" : {"policy": {"invite": {"pending": []}}},
                     "module"     : "publish",
                     "mark"       : "graph-validator-publish"
                    }
         })
    end

    def create_post_json(author, title, body)
      time = Time.now.to_i
      index = Urbit::Node.unix_to_da(time)
      %Q({
         "add-nodes": {
           "resource": {"ship": "#{self.host_ship}", "name": "#{self.name}"},
           "nodes": {
             "/#{index}": {
               "post": {"author": "#{author}", "index": "/#{index}", "time-sent": #{time}, "contents": [], "hash": null, "signatures": []},
               "children": {
                 "1": {
                   "post": { "author": "#{author}", "index": "/#{index}/1", "time-sent": #{time}, "contents": [], "hash": null, "signatures": []},
                   "children": {
                     "1": {
                       "post": {"author": "#{author}", "index": "/#{index}/1/1", "time-sent": #{time}, "contents": [{"text": "#{title}"}, {"text": "#{body}"}], "hash": null, "signatures": []},
                       "children": null
                     }
                   }
                 },
                 "2": {
                   "post": {"author": "#{author}", "index": "/#{index}/2", "time-sent": #{time}, "contents": [], "hash": null, "signatures": []},
                   "children": null
                 }
               }
             }
           }
         }
      })
    end
  end
end
