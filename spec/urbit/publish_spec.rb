require 'json'
require "urbit/node"
require "urbit/ship"

describe Urbit::Ship do
  before(:all) do
    @ship_name = "~zod"
    @index = "170141184505913806450093257495119034056"
    # We need a unique, but shared name for the graph.
    @publish_graph_name = SecureRandom.hex(5)
  end

  context "When using %publish" do
    let(:ship) { described_class.new }


    it "can create an 'unmanaged' graph using 'spider'" do
      ship.login
      expect(ship.graphs.count).to eq(1)   # this is the default dm-inbox

      create_graph_json = %Q({
        "create": {
          "resource": {"ship": "~zod", "name": "#{@publish_graph_name}"},
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
           "resource": {"ship": "#{@ship_name}", "name": "#{@publish_graph_name}"},
           "nodes": {
             "/#{@index}": {
               "post": {"author": "#{@ship_name}", "index": "/#{@index}", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
               "children": {
                 "1": {
                   "post": { "author": "#{@ship_name}", "index": "/#{@index}/1", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
                   "children": {
                     "1": {
                       "post": {"author": "#{@ship_name}", "index": "/#{@index}/1/1", "time-sent": #{@time}, "contents": [{"text": "#{@title}"}, {"text": "#{@body}"}], "hash": null, "signatures": []},
                       "children": null
                     }
                   }
                 },
                 "2": {
                   "post": {"author": "#{@ship_name}", "index": "/#{@index}/2", "time-sent": #{@time}, "contents": [], "hash": null, "signatures": []},
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
      # e.g. {\"pending-indices\":{\"/170141184505913806450093257495119034056\":\"0x8326.753f.9743.6590.373c.d74c.b57a.7e9f\"}}
      expect(spider[:body]).to   include("pending-indices")

      @new_node = ship.graph(resource: "#{@ship_name}/#{@publish_graph_name}").newest_nodes(count: 1).first
      expect(@new_node).to_not be_nil

      @remove_doc_json = {"remove-posts": {"resource": {"ship": "#{@ship_name}", "name": "#{@publish_graph_name}"}, "indices": ["/#{@new_node.raw_index}"]}}

      poke_channel = ship.poke(app: "graph-push-hook", mark: "graph-update-3", message: @remove_doc_json)
      expect(poke_channel.subscribed?)
    end

    it "can delete an 'unmanaged' graph using 'spider'" do ship.login
      expect(ship.graphs(flush_cache: true).count).to eq(2)   # We have added in our new graph


      delete_graph_json = %Q({
        "delete": {
          "resource": {
            "ship": "~zod",
            "name": "#{@publish_graph_name}"
          }
        }
      })

      spider = ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-delete', data: delete_graph_json, args: ["NO_RESPONSE"])
      expect(spider[:status]).to eq(200)
      expect(spider[:code]).to eq("ok")
      expect(spider[:body]).to eq("null")

      expect(ship.graphs.count).to eq(1)   # We have removed the new graph and are back to only dm-inbox
    end

  end
end