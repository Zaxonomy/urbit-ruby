require 'json'
require "urbit/graph"
require "urbit/node"
require "urbit/ship"

describe Urbit::Ship do
  before(:all) do
    @index = "170141184505913806450093257495119034056"
    # We need a unique, but shared name for the graph.
    @publish_graph_name_1 = SecureRandom.hex(5)
    @publish_graph_name_2 = SecureRandom.hex(5)
  end

  context "When using %publish" do
    let(:ship) { described_class.new }

    it "can create an 'unmanaged' 'publish' graph using 'spider'" do
      ship.login
      expect(ship.graphs.count).to eq(1)   # this is the default dm-inbox

      create_graph_json = %Q({
        "create": {
          "resource": {"ship": "#{ship.name}", "name": "#{@publish_graph_name_1}"},
          "title": "TUG",
          "description": "Testing Un-Managed Publish Graph Creation",
          "associated": {"policy": {"invite": {"pending": []}}},
          "module"     : "publish",
          "mark"       : "graph-validator-publish"
        }
      })

      spider = ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-create', data: create_graph_json)
      expect(spider[:status]).to eq(200)
      expect(spider[:code]).to eq("ok")
      expect(spider[:body]).to eq("null")

      expect(ship.graphs(flush_cache: true).count).to eq(2)   # We have added in our new graph
    end

    it "can create a document in the %publish channel using spider and then remove it." do
      ship.login

      @time = (Urbit::Node.unix_to_da(Time.now.to_i)).to_s
      @title = "Post 0"
      @body = "This is a test Post via the Airlock using a thread."

      @create_doc_json = %Q({
         "add-nodes": {
           "resource": {"ship": "#{ship.name}", "name": "#{@publish_graph_name_1}"},
           "nodes": {
             "/#{@index}": {
               "post": {"author": "#{ship.name}", "index": "/#{@index}", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
               "children": {
                 "1": {
                   "post": { "author": "#{ship.name}", "index": "/#{@index}/1", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
                   "children": {
                     "1": {
                       "post": {"author": "#{ship.name}", "index": "/#{@index}/1/1", "time-sent": #{@time}, "contents": [{"text": "#{@title}"}, {"text": "#{@body}"}], "hash": null, "signatures": []},
                       "children": null
                     }
                   }
                 },
                 "2": {
                   "post": {"author": "#{ship.name}", "index": "/#{@index}/2", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
                   "children": null
                 }
               }
             }
           }
         }
      })

      spider = ship.spider(desk: 'landscape', mark_in: 'graph-update-3', mark_out: 'graph-view-action', thread: 'graph-add-nodes', data: @create_doc_json)
      expect(spider[:status]).to eq(200)
      expect(spider[:code]).to   eq("ok")
      expect(spider[:body]).to   include("pending-indices")   # e.g. {\"pending-indices\":{\"/170141184505913806450093257495119034056\":\"0x8326.753f.9743.6590.373c.d74c.b57a.7e9f\"}}

      new_node = ship.graph(resource: "#{ship.name}/#{@publish_graph_name_1}").newest_nodes(count: 1).first
      expect(new_node).to_not be_nil

      remove_doc_json = {"remove-posts": {"resource": {"ship": "#{ship.name}", "name": "#{@publish_graph_name_1}"}, "indices": ["/#{new_node.raw_index}"]}}

      poke_channel = ship.poke(app: "graph-push-hook", mark: "graph-update-3", message: remove_doc_json)
      expect(poke_channel.subscribed?)
    end

    it "can add and remove a post to a publish graph via a helper method" do
      graph = Urbit::PublishGraph.new(ship: ship, graph_name: @publish_graph_name_2, title: "New Publish Graph", description: "For testing purposes only")
      graph.persist
      expect(graph.persistent?)

      graph.add_post(author: ship.name, title: 'Cool Posting', body: 'Look ma, no JSON!')

      new_node = graph.newest_nodes(count: 1).first
      expect(new_node).to_not be_nil

      graph.delete
      expect(!graph.persistent?)
    end

    it "can delete an 'unmanaged' graph using 'spider'" do
      ship.login
      expect(ship.graphs(flush_cache: true).count).to eq(2)   # We have added in our new graph

      delete_graph_json = %Q({"delete": {"resource": {"ship": "#{ship.name}", "name": "#{@publish_graph_name_1}"}}})

      spider = ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-delete', data: delete_graph_json, args: ["NO_RESPONSE"])
      expect(spider[:status]).to eq(200)
      expect(spider[:code]).to eq("ok")
      expect(spider[:body]).to eq("null")

      expect(ship.graphs.count).to eq(1)   # We have removed the new graph and are back to only dm-inbox
    end

  end
end