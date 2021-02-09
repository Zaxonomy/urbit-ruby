require 'faraday'
require 'SecureRandom'

require 'urbit/channel'
require 'urbit/config'

module Urbit
  class Ship
    attr_accessor :logged_in
    attr_reader :auth_cookie, :channels, :config

    def initialize(config: Config.new)
      @auth_cookie = nil
      @channels = []
      @config = config
      @logged_in = false
    end

    def self.finalize(channels)
      proc { channels.each { |c| c.close } }
    end

    def logged_in?
      logged_in
    end

    def cookie
      auth_cookie
    end

    def login
      return if logged_in?

      ensure_connections_closed
      response = Faraday.post(login_url, "password=#{config.code}")
      parse_cookie(response)
    end

    def name
      config.name
    end
    
    def parse_cookie(resp)
      cookie = resp.headers['set-cookie']
      return unless cookie
      
      @auth_cookie, @path, @max_age = cookie.split(';')
      self.logged_in = true if @auth_cookie
    end
    
    def pat_p
      config.name
    end

    # Opening a channel always creates a new channel which will
    # remain open until this ship is disconnected at which point it
    # will be closed.
    def open_channel(a_name)
      login
      (c = Channel.new self, a_name).send_message("Opening Airlock")
      self.channels << c

      c
    end

    def open_channels
      @channels.select {|c| c.open?}
    end

    private

    def ensure_connections_closed
      # Make sure all our created channels are closed by the GC
      ObjectSpace.define_finalizer( self, self.class.finalize(channels) )
    end

    def login_url
      "#{config.api_base_url}/~/login"
    end
  end
end
