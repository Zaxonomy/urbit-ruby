require 'set'

require "urbit/graph"
require "urbit/ship"

describe Urbit::Graph do
  let(:ship) { Urbit::Ship.new }
  let(:name) {'announce'}
  let(:graph) {
    ship.login
    described_class.new(ship, name, 'darlur')
  }

  after(:each) do
  end

  it "is initialized with a name and the name of its host ship" do
    expect(graph.name).to_not be_nil
    expect(graph.name).to eq(name)
  end

  it "can be represented as a string" do
    expect(graph.to_s).to eq("a Graph(~darlur/announce)")
  end

  it "retrieving the newest messages from an empty graph is an empty set" do
    expect(graph.newest_nodes).to be_empty
  end

  it "rejects adding the same node index twice" do
    expect(graph.nodes.empty?)
    np1 = Urbit::AddNodesParser.new(for_graph: graph,
                                    with_json: {'resource' => {'name' => 'announce', 'ship' => 'darlur'},
                                           'nodes' => { '/17014' => {'post' => {'index' => '/17014', 'time-sent' => 1619191801085, 'contents' => []}}}})
    np1.add_nodes
    expect(graph.nodes.size).to eq(1)

    np2 = Urbit::AddNodesParser.new(for_graph: graph,
                                    with_json: {'resource' => {'name' => 'announce', 'ship' => 'darlur'},
                                     'nodes' => { '/17014' => {'post' => {'index' => '/17014', 'time-sent' => 1619191801085, 'contents' => []}}}})
    np2.add_nodes
    expect(graph.nodes.size).to eq(1)
  end

  it "can fetch the newest messages from a graph" do
    # NOTE: This test will fail if you don''t have a fake zod running.
    ship.login
    expect(ship.graphs.first).to be_instance_of(Urbit::Graph)
    expect(ship.graphs.first.newest_nodes).to be_instance_of(Set)
    # expect(ship.graphs.first.newest_messages).to_not be_empty
  end
end
