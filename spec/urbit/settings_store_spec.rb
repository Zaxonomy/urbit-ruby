require 'json'
require "urbit/ship"

# ------------------------------------------------------------------
# Settings Store Tests
# ------------------------------------------------------------------
describe Urbit::Ship do
  context "When using %settings-store" do
    let(:ship) { described_class.new }
    # We need a unique name for the graph each time or the test will fail.
    let(:random_name) {SecureRandom.hex(5)}

    it "has no Settings collection if never logged in" do
      expect(ship.logged_in?).to be false
      expect(ship.settings).to be_nil
    end

    it "can query and retrieves settings if logged in" do
      # At least for now, all fake ships THAT HAVE NEVER BEEN LOGGED IN IN A BROWSER
      # come with settings for a 'bitcoin' desk which has a 'btc-wallet' bucket...
      ship.login
      expect(ship.logged_in?)
      expect(ship.settings[desk: "bitcoin"]).to_not be_nil

      s = ship.settings[desk: "bitcoin"]
      expect(s).to be_instance_of(Urbit::Setting)
      expect(s[bucket: "btc-wallet"]).to_not be_nil
      expect(s[bucket: "btc-wallet"].entries).to eq({"currency"=>"USD", "warning"=>true})

      # There are setting for 'garden' and 'bitcoin' by default...
      expect(ship.settings.count).to be(1)
    end
  end
end