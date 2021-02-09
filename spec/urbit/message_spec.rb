require 'urbit/channel'
require 'urbit/message'
require 'urbit/ship'

describe Urbit::Message do
  let(:ship) { Urbit::Ship.new }
  let(:channel) { Urbit::Channel.new ship, "Test Channel" }

  it "can be initialized" do
    m = Urbit::Message.new channel, 1, "poke", "hood", "helm-hi", "Test Message"
    expect(m.id).to_not be_nil
  end

  it "can serialize itself as json" do
    m = Urbit::Message.new channel, 1, "poke", "hood", "helm-hi", "Test Message"
    j = JSON.parse m.request_body
    expect(j['id']).to eq(1)
    expect(j['ship']).to eq("zod")
  end

  it "can serialize itself as a json string" do
    m = Urbit::Message.new channel, 1, "poke", "hood", "helm-hi", "Opening airlock"
    expect(m.request_body).to eq('{"action":"poke","app":"hood","id":1,"json":"Opening airlock","mark":"helm-hi","ship":"zod"}')
  end
end

# curl --header "Content-Type: application/json"
#      --cookie "urbauth-~zod=0v3.okvjc.4segg.g1mh8.32pkn.silsv"
#      --request PUT
#       --data '[{"id":1,"action":"poke","ship":"zod","app":"hood","mark":"helm-hi","json":"Opening airlock"}]'
#   http://localhost:8080/~/channel/1601844290-ae45b