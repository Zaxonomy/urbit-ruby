describe Urbit::Api::Message do
  before(:all) do
    @ship = Urbit::Api::Ship.new
    @c = Urbit::Api::Channel.new @ship, "Test Channel"
  end

  it "can be initialized" do
    m = Urbit::Api::Message.new @c, 1, "poke", "hood", "helm-hi", "Test Message"
    expect(m.id).to_not be_nil
  end

  it "can serialize itself as json" do
    m = Urbit::Api::Message.new @c, 1, "poke", "hood", "helm-hi", "Test Message"
    j = JSON.parse m.as_json
    expect(j['id']).to eq(1)
    expect(j['ship']).to eq("zod")
  end

  it "can serialize itself as a json string" do
    m = Urbit::Api::Message.new @c, 1, "poke", "hood", "helm-hi", "Opening airlock"
    expect(m.as_json).to eq('{"id":1,"ship":"zod","action":"poke","app":"hood","mark":"helm-hi","json":"Opening airlock"}')
  end
end

# curl --header "Content-Type: application/json"
#      --cookie "urbauth-~zod=0v3.okvjc.4segg.g1mh8.32pkn.silsv"
#      --request PUT
#       --data '[{"id":1,"action":"poke","ship":"zod","app":"hood","mark":"helm-hi","json":"Opening airlock"}]'
#   http://localhost:8080/~/channel/1601844290-ae45b