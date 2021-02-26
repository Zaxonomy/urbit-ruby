require 'urbit/channel'
require 'urbit/message'
require 'urbit/ship'

describe Urbit::Message do
  let(:ship) { Urbit::Ship.new }
  let(:channel) { Urbit::Channel.new ship, "Test Channel" }

  it "can be initialized" do
    m = Urbit::Message.new channel, "poke", "hood", "helm-hi", "Test Message"
    expect(m.id).to_not be_nil
  end

  it "can serialize itself as json" do
    m = Urbit::Message.new channel, "poke", "hood", "helm-hi", "Test Message"
    j = JSON.parse m.request_body
    # NOTE: A message's id when first created is Zero and thus can't be sent yet.
    expect(j.first['id']).to eq(0)
    expect(j.first['ship']).to eq("zod")
  end

  it "can serialize itself as a json string" do
    m = Urbit::Message.new channel, "poke", "hood", "helm-hi", "Opening airlock"
    expect(m.request_body).to eq('[{"action":"poke","app":"hood","id":0,"json":"Opening airlock","mark":"helm-hi","ship":"zod"}]')
  end
end
