require "urbit/node"
require "urbit/ship"

describe Urbit::Node do
  let(:ship) { Urbit::Ship.new }
  let(:graph) { ship.login.graphs.first }

  let(:raw_index) { '/170141184505020984719232265951207489536/2' }
  let(:index) { '170141184505020984719232265951207489536/2' }

  let(:node_json) {{
    "post" => {
      "index" => "/170141184505020984719232265951207489536/2",
      "author" => "barsyr-latreb",
      "time-sent" => 1619191801085,
      "signatures"=> [{
          "signature" => "0x1.284d.9ddd.b0ca", "life" => 3, "ship" => "barsyr-latreb"
      }],
      "contents" => [],
      "hash"     =>"0x9426.ceee.d865.1dbb.e711.5f52.27d6.880c"
    }
  }}

  let(:node) { described_class.new(index, node_json)}

  after(:each) do
  end

  it "is initialized with an index derived by stripping off the initial forward slash" do
    expect(node.index).to eq(index)
  end

  it "knows the time it was sent" do
    expect(node.time_sent).to eq(1619191801085)
  end

  it "constructs the contents from the post" do
    expect(node.contents).to eq([])
  end

  it "can be represented as a string" do
    expect(node.to_s).to eq("a Node(#{index}) => {time_sent: 1619191801085, contents: []}")
  end

  it "considers nodes with the same index to be the same" do
    node2 = described_class.new(index, node_json)
    expect(node2).to eq(node)
  end

  # it "retrieving the newest messages from an empty graph is an empty set" do
  #   expect(graph.newest_messages).to be_empty
  # end
end
