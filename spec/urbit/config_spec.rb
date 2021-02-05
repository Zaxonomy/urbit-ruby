require "urbit/api"

describe Urbit::Api::Config do
  before(:each) do
    @c = Urbit::Api::Config.new
  end

  it "reads in the ship code" do
    expect(@c.ship_code).to eq('lidlut-tabwed-pillex-ridrup')
  end

  it "reads in the ship name" do
    c = Urbit::Api::Config.new
    expect(@c.ship_name).to eq('~zod')
  end
end