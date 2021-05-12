require "urbit/node"
require "urbit/ship"

describe Urbit::Node do
  let(:ship) { Urbit::Ship.new }
  let(:graph) { ship.login.graphs.first }

  let(:raw_index) { '/170141184505020984719232265951207489536/2' }
  let(:index) { '170141184505020984719232265951207489536/2' }
  let(:node_json) {
    {
      "post" => {
        "index" => "/170141184505020984719232265951207489536/2",
        "author" => "barsyr-latreb",
        "time-sent" => 1619191801085,
        "signatures"=> [
          {
            "signature" => "0x1.284d.9ddd.b0ca.3b77.ce22.bea4.4fad.1018.0200.fb46.de9e.541a.7c0d.c680.20a3.986c.ce0f.944b.4f48.cdb1.64aa.bc8a.ce34.c7ee.bcc4.47ce.7dd2.8b98.12b8.c69b.98ae.73e3.3a40.592e.11b2.1445.6cbf.bfbc.6e60.6815.e1bf.7001",
            "life"=>3,
            "ship"=>"barsyr-latreb"
          }
        ],
        "contents" => [],
        "hash"     =>"0x9426.ceee.d865.1dbb.e711.5f52.27d6.880c"
      }
    }
  }

  let(:node) { described_class.new(index, node_json)}

  after(:each) do
  end

  it "is initialized with an index derived by stripping off the initial forward slash" do
    expect(node.index).to eq(index)
  end

  it "can be represented as a string" do
    expect(node.to_s).to eq("a Node(#{index}) => {time_sent: 1619191801085, contents: []}")
  end

  # it "retrieving the newest messages from an empty graph is an empty set" do
  #   expect(graph.newest_messages).to be_empty
  # end
end
