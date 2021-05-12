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
    expect(graph.to_s).to eq("a Graph named 'announce' hosted on ~darlur")
  end

  it "retrieving the newest messages from an empty graph is an empty set" do
    expect(graph.newest_messages).to be_empty
  end
end
