require 'json'
require "urbit/ship"

describe Urbit::Ship do
  let(:ship) { described_class.new }
  # We need a unique name for the graph each time or the test will fail.
  let(:random_name) {SecureRandom.hex(5)}

  let(:create_json) {
    %Q({
      "create": {
        "resource"   : {
          "ship": "~zod",
          "name": "#{random_name}"
        },
        "title"      : "Testing creation",
        "description": "test",
        "associated" : {
          "policy": {
            "invite": {
              "pending": []
            }
          }
        },
        "module"     : "chat",
        "mark"       : "graph-validator-chat"
      }
    })
  }

  it "has a pat p" do
    expect(ship.pat_p).to_not be_nil
    expect(ship.pat_p).to eq("~zod")
  end

  it "is not initially logged in" do
    expect(ship.logged_in?).to be false
  end

  it "can log in" do
    # NOTE: This test will fail if you don''t have a fake zod running.
    ship.login
    expect(ship.logged_in?)
    expect(ship.cookie).to_not be_nil
  end

  it "can be represented as a string" do
    expect(ship.to_s).to eq('a Ship({:name=>"~zod", :host=>"http://localhost", :port=>"8080"})')
  end

#   # ------------------------------------------------------------------
#   # Subscribing
#   # ------------------------------------------------------------------
  it "can subscribe" do
    expect(channel = ship.subscribe(app: 'graph-store', path: '/updates')).to_not be_nil
  end

  it "can subscribe which opens a channel" do
    expect(ship.open_channels.size).to eq(0)
    ship.subscribe(app: 'graph-store', path: '/updates')
    # This is channel 2, not 0 or 1, because initializing the ship now opens channels for the Groups and Metadata.
    expect(ship.open_channels.size).to eq(3)

    c = ship.open_channels.last
    expect(c).to be_instance_of(Urbit::Channel)
    c.close
  end

  it "subscribe answers a new Channel with a Receiver listening to response messages" do
    channel = ship.subscribe(app: 'graph-store', path:'/updates')
    expect(channel).to be_instance_of(Urbit::Channel)
    expect(channel.receiver).to be_instance_of(Urbit::Receiver)
  end

  it "closing the channel makes it unavailable" do
    ship.subscribe(app: 'graph-store', path: '/updates')
    c = ship.open_channels.last
    c.close
    expect(ship.open_channels.size).to eq(2)
  end

#   # ------------------------------------------------------------------
#   # Poke
#   # ------------------------------------------------------------------
  it "can initiate a DM by poking the %hood app with a message using the %helm-hi mark" do
    poke_channel = ship.poke(app: 'hood', mark: 'helm-hi', message: 'Opening Airlock')
    expect(poke_channel.subscribed?)
  end

  # ------------------------------------------------------------------
  # Scry
  # ------------------------------------------------------------------
  it "can scry" do
    ship.login
    scry = ship.scry(app: 'settings-store', path: '/desk/garden', mark: 'json')
    expect(scry[:status]).to eq(200)
    expect(scry[:code]).to eq("ok")
    expect(scry[:body]).to eq("{\"desk\":{}}")
  end

  it "returns 404/missing when scrying nonsense" do
    ship.login
    scry = ship.scry(app: 'soft-server', path: '/vanilla/fudge/hash', mark: 'json')
    expect(scry[:status]).to eq(404)
    expect(scry[:code]).to eq("missing")
    expect(scry[:body]).to include("")
  end

  it "uses json as the default mark for scry" do
    ship.login
    scry = ship.scry(app: 'graph-store', path: '/keys')
    expect(scry[:status]).to eq(200)
    expect(scry[:code]).to eq("ok")
    expect(scry[:body]).to match(/graph-update/)
  end

  # ------------------------------------------------------------------
  # Spider
  # ------------------------------------------------------------------
  # Running threads is an exception to the rule that we outlined in the section on channels.
  # It uses a POST request and both manipulates state and receives information back.
  # It also exposes the ability to send a sequence of commands, i.e. a "thread," hence the name.
  #
  # It takes the form {url}/spider/{desk}/{inputMark}/{threadname}/{outputmark}.json
  #
  # 'landscape' is the default desk if not provided like we did here.
  # ------------------------------------------------------------------
  it "can create a chat graph using spider" do
    ship.login
    expect(ship.graphs.count).to eq(1)   # this is the default dm-inbox

    spider = ship.spider(desk: 'landscape', mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-create', data: create_json)
    expect(spider[:status]).to eq(200)
    expect(spider[:code]).to eq("ok")
    expect(spider[:body]).to eq("null")

    expect(ship.graphs(flush_cache: true).count).to eq(2)   # add in our new graph
    new_graph = ship.graphs.select {|g| random_name == g.name}.first
    ship.remove_graph(graph: new_graph)
    expect(ship.graphs.count).to eq(1)   # this is just the default dm-inbox again
  end

  # it "can fetch a url using spider" do
  #   ship.login
  #   fetch_json = %q({
  #     "create": {
  #        "resource"   : {"ship": "~zod", "name": "test2"},
  #        "title"      : "Testing URL Fetch",
  #        "description": "test",
  #        "associated" : {"policy": {"invite": {"pending": []}}},
  #        "module"     : "chat",
  #        "mark"       : "graph-validator-chat"
  #     }
  #   })
  #   spider = ship.spider('graph-view-action', 'json', 'graph-create', fetch_json)
  #   expect(spider[:status]).to eq(200)
  #   expect(spider[:code]).to eq("ok")
  #   expect(spider[:body]).to eq("null")
  # end

  #-------------------------------------------------------------------
  # This test is a tricky one and I couldn't get it to work.
  # You can, however, assure yourself that it is actually true by
  # uncommenting the "puts" in channel.close and you'll see it is
  # called when your program ends.
  #-------------------------------------------------------------------
  # it test_destroying_a_ship_closes_all_its_channels
  #   c = ship.open_channel "Test Channel"
  #   assert_equal 1, ship.open_channels.size
  #   assert c.subscribed?
  #   instance = nil
  #   GC.start(full_mark: true, immediate_sweep: true)
  #   sleep 15
  #   assert c.closed?
  # end

#   # ------------------------------------------------------------------
#   # Graph Store
#   # ------------------------------------------------------------------
  it "has an empty collection of Graphs if never logged in" do
    expect(ship.logged_in?).to be false
    expect(ship.graphs).to be_empty
  end

  it "queries and retrieves graphs if logged in" do
    ship.login
    expect(ship.logged_in?)
    expect(ship.graphs).to_not eq([])
    expect(ship.graphs.first).to be_instance_of(Urbit::Graph)
    # expect(ship.graphs.count).to be(5)
  end

  it "can retrieve the newest messages from one of its graphs" do
    ship.login
    # Make a graph...
    spider = ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-create', data: create_json)
    expect(ship.graphs(flush_cache: true).count).to eq(2)   # add in our new graph
    new_graph = ship.graphs.select {|g| random_name == g.name}.first
    # expect(new_graph.newest_messages).to_not be_empty
    # Clean up
    ship.remove_graph(graph: new_graph)
  end

  # ------------------------------------------------------------------
  # Group Store
  # ------------------------------------------------------------------
#  leave_json = %q({"leave": {{"ship": "~bitbet-bolbel", "name": "urbit-community"}})
#  ship.spider(desk: 'landscape', mark_in: 'group-view-action', mark_out: 'json', thread: 'group-leave', data: %q({"leave": {"ship":"~bitbet-bolbel", "name":"urbit-community"}}))

#  ship.poke(app: 'group-view', mark: 'group-view-action', message: {join: {resource: {ship: '~fabled-faster', name: 'interface-testing-facility'}, ship: '~fabled-faster', shareContact: false, app: 'groups', autojoin: false}})
#  ship.poke(app: 'group-view', mark: 'group-view-action', message: {done: "/ship/~fabled-faster/interface-testing-facility"})
#
# leave_json_string = %q({"leave": {"ship": "~fabled-faster", "name": "interface-testing-facility"}})
# ship.spider(desk: 'landscape', mark_in: 'group-view-action', mark_out: 'json', thread: 'group-leave', data: leave_json_string)
# ship.spider(desk: 'landscape', mark_in: 'group-view-action', mark_out: 'json', thread: 'group-leave', data: %q({"leave": {"ship": "~fabled-faster", "name": "interface-testing-facility"}}))

end