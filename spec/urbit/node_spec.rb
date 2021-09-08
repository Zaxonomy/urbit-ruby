require "urbit/node"
require "urbit/ship"

describe Urbit::Node do
  let(:ship) { Urbit::Ship.new }
  let(:graph) { ship.login.graphs.first }

  let(:raw_index) { '/170141184505036957608427254348286787584' }
  let(:index) { '170141184505036957608427254348286787584' }

  let(:node_json) {{
    "post" => {
      "index" => "/170141184505036957608427254348286787584",
      "author" => "darlur",
      "time-sent" => 1620057693019,
      "signatures"=> [{
          "signature" => "0x5468.e5ec.1955.3e10.14a6.5fc0.054e.0e1b.fe01.1272.0a2c.e3c8.37a5.6717.ed7d.4b0c.3102.3966.4caa.edeb.e89e.3194.be17.f6a7.0622.4775.5e8f.7e92.16d2.c552.5ecd.d28b.17a6.aad5.089b.3623.eb8b.1b62.1525.0571.2d9f.9001",
          "life" => 3,
          "ship" => "darlur"
      }],
      "contents" => [{"text" => "We are now running urbit v1.5."}],
      "hash"     => "0x5468.e5ec.1955.3e10.14a6.5fc0.054e.0e1b"
    }
  }}

  let(:node) { described_class.new(graph: raw_index, node_json: node_json)}

  after(:each) do
  end

  it "is initialized with an index derived by stripping off the initial forward slash and stored as the raw_index" do
    expect(node.raw_index).to eq(index)
  end

  it "knows the time it was sent" do
    expect(node.time_sent).to eq(1620057693019)
  end

  it "constructs the contents from the post" do
    expect(node.contents).to eq([{"text" => "We are now running urbit v1.5."}])
  end

  it "can be represented as a string" do
    expect(node.to_s).to eq("a Node(#{node.to_h})")
  end

  it "considers nodes with the same index to be the same" do
    node2 = described_class.new(graph: index, node_json: node_json)
    expect(node2).to eq(node)
  end

  it "knows whether it was fetched/saved from/to urbit and hence is persistent" do
    # This node was just contructed so it isn't persistent.
    expect(node.persistent?).to be false
  end

  it "represents the index as an atom" do
    expect(node.index).to eq("170.141.184.505.036.957.608.427.254.348.286.787.584")
  end

  it "properly converts smaller indexes to atoms" do
    min_json = {"post" => {"index" => "/17014", "author" => "darlur", "time-sent" => 1620057693019, "contents" => [], "hash" => "0x5468.e5ec.1955.3e10.14a6.5fc0.054e.0e1b"}}
    n = Urbit::Node.new(graph: graph, node_json: min_json)
    expect(n.index).to eq("17.014")
  end

  it "properly handles multi-part indexes" do
    min_json = {"post" => {"index" => "/3830645248/170141184505210819602640237844462829568",
                          "author" => "darlur", "time-sent" => 1620057693019, "contents" => [], "hash" => "0x5468.e5ec.1955.3e10.14a6.5fc0.054e.0e1b"}}
    n = Urbit::Node.new(graph: graph, node_json: min_json)
    expect(n.index).to eq("3.830.645.248/170.141.184.505.210.819.602.640.237.844.462.829.568")
  end
  # it "retrieving the newest messages from an empty graph is an empty set" do
  #   expect(graph.newest_messages).to be_empty
  # end
end
