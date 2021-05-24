require 'json'
require "urbit/ship"

describe Urbit::Ship do
  let(:ship) { described_class.new }

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
    expect(ship.to_s).to eq("a Ship(name: '~zod', host: 'http://localhost', port: '8080')")
  end

  # ------------------------------------------------------------------
  # Subscribing
  # ------------------------------------------------------------------
  it "can subscribe" do
    expect(receiver = ship.subscribe('graph-store', '/updates')).to_not be_nil
  end

  it "can subscribe which opens a channel" do
    expect(ship.open_channels.size).to eq(0)
    ship.subscribe('graph-store', '/updates')
    expect(ship.open_channels.size).to eq(1)

    c = ship.open_channels.last
    expect(c).to be_instance_of(Urbit::Channel)
    c.close
  end

  it "subscribe answers a new receiver listening to response messages" do
    receiver = ship.subscribe('graph-store', '/updates')
    expect(receiver).to be_instance_of(Urbit::Receiver)
  end

  it "closing the channel makes it unavailable" do
    ship.subscribe('graph-store', '/updates')
    c = ship.open_channels.last
    c.close
    expect(ship.open_channels.size).to eq(0)
  end

  # ------------------------------------------------------------------
  # Scry
  # ------------------------------------------------------------------
  it "can scry" do
    ship.login
    scry = ship.scry('file-server', '/clay/base/hash', 'json')
    expect(scry[:status]).to eq(200)
    expect(scry[:code]).to eq("ok")
    expect(scry[:body]).to eq("\"0\"")
  end

  it "returns 404/missing when scrying nonsense" do
    ship.login
    scry = ship.scry('soft-server', '/vanilla/fudge/hash', 'json')
    expect(scry[:status]).to eq(404)
    expect(scry[:code]).to eq("missing")
    expect(scry[:body]).to include("")
  end

  it "uses json as the default mark for scry" do
    ship.login
    scry = ship.scry('graph-store', '/keys')
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
  # It takes the form {url}/spider/{inputMark}/{threadname}/{outputmark}.json
  # ------------------------------------------------------------------
  it "can create a chat graph using spider" do
    # We need a unique name for the graph each time or the test will fail.
    # TODO: This test is "polluting" our fake zod with lots of graphs but I haven't figured out how to remove them yet.
    random_name = SecureRandom.hex(5)

    ship.login
    create_json = %Q({
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

    spider = ship.spider('graph-view-action', 'json', 'graph-create', create_json)
    expect(spider[:status]).to eq(200)
    expect(spider[:code]).to eq("ok")
    expect(spider[:body]).to eq("null")
  end

it "can create an 'unmanaged' graph using 'spider' and then delete it with a 'poke'" do
  random_name = SecureRandom.hex(5)

  ship.login
  create_json = %Q({
    "create": {
      "resource": {
        "ship": "~zod",
        "name": "#{random_name}"
      },
      "title": "TUG",
      "description": "Testing Un-Managed Graph Creation",
      "associated": {
        "policy": {
          "invite": {
            "pending": []
          }
        }
      },
      "module"     : "publish",
      "mark"       : "graph-validator-publish"
    }
  })

  spider = ship.spider('graph-view-action', 'json', 'graph-create', create_json)
  expect(spider[:status]).to eq(200)
  expect(spider[:code]).to eq("ok")
  expect(spider[:body]).to eq("null")

  delete_json = %Q({
    "delete": {
      "resource": {
        "ship": "~zod",
        "name": "#{random_name}"
      }
    }
  })

    receiver = ship.poke('graph-push-hook', 'graph-update-2', delete_json)

    expect(receiver.open?)
    expect(receiver.facts.count).to eq(1)
    # expect(spider[:code]).to eq("ok")
    # expect(spider[:body]).to eq("null")
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

  # ------------------------------------------------------------------
  # Graph Store
  # ------------------------------------------------------------------
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

  # it "can retrieve the newest messages from one of its graphs" do
  #   ship.login
  #   expect(ship.logged_in?)
  #   expect(ship.graphs).to_not eq([])
  #   expect(ship.graphs.first.newest_messages).to_not be_empty
  # end
end