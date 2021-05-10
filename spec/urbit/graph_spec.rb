require "urbit/graph"

describe Urbit::Graph do
  let(:name) {'announce'}
  let(:graph) { Urbit::Graph.new(name, 'darlur') }

  after(:each) do
  end

  it "is initialized with a name and the name of its host ship" do
    expect(graph.name).to_not be_nil
    expect(graph.name).to eq(name)
  end

  it "can be represented as a string" do
    expect(graph.to_s).to eq("a Graph named 'announce' hosted on ~darlur")
  end

end
