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
    expect(graph.to_s).to eq("~darlur/announce")
  end

  it "retrieving the newest messages from an empty graph is an empty set" do
    expect(graph.newest_messages).to be_empty
  end

  it "rejects adding the same node index twice" do
    n1 = Urbit::Node.new('/123', '"post" => {"time-sent" => 1619191801085, "contents" => []}')
    n2 = Urbit::Node.new('/123', '"post" => {"time-sent" => 1619191801085, "contents" => []}')
    expect(graph.nodes.empty?)
    graph.add_node(n1)
    expect(graph.nodes.size).to eq(1)
    graph.add_node(n2)
    expect(graph.nodes.size).to eq(1)
  end

  it "can fetch the newest messages from a graph" do
    # NOTE: This test will fail if you don''t have a fake zod running.
    ship.login
    expect(ship.graphs.first).to be_instance_of(Urbit::Graph)
    expect(ship.graphs.first.newest_messages).to be_instance_of(Set)
    expect(ship.graphs.first.newest_messages).to_not be_empty
  end
end
