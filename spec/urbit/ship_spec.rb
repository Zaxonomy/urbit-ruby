describe Urbit::Api::Ship do
  before(:each) do
    @ship = Urbit::Api::Ship.new
  end

  it "has a pat p" do
    expect(@ship.pat_p).to_not be_nil
    expect(@ship.pat_p).to     eq("~zod")
  end

  it "is not initially logged in" do
    expect(@ship.logged_in?).to be false
  end

  it "can log in" do
    # NOTE: This test will fail if you don''t have a fake zod running.
    @ship.login
    expect(@ship.logged_in?)
    expect(@ship.cookie).to_not be_nil
  end

   it "can open a channel" do
     c = @ship.open_channel "Test Channel"
     expect(@ship.open_channels.size).to eq(1)
    c.close
   end

  it "test opening the channel answers the new channel" do
    c = @ship.open_channel "Test Channel"
    expect(c).to be_instance_of(Urbit::Api::Channel)
    c.close
  end

  it "closing the channel makes it unavailable" do
    c = @ship.open_channel "Test Channel"
    expect(@ship.open_channels.size).to eq(1)
    c.close
    expect(@ship.open_channels.size).to eq(0)
  end

  #-------------------------------------------------------------------
  # This test is a tricky one and I couldn't get it to work.
  # You can, however, assure yourself that it is actually true by
  # uncommenting the "puts" in channel.close and you'll see it is
  # called when your program ends.
  #-------------------------------------------------------------------
  # it test_destroying_a_ship_closes_all_its_channels
  #   c = @ship.open_channel "Test Channel"
  #   assert_equal 1, @ship.open_channels.size
  #   assert c.open?
  #   @ship = nil
  #   GC.start(full_mark: true, immediate_sweep: true)
  #   sleep 15
  #   assert c.closed?
  # end
end
