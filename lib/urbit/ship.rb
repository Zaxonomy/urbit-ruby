require 'faraday'

require 'urbit/channel'
require 'urbit/config'
require 'urbit/graph'

module Urbit
  class Ship
    attr_accessor :logged_in
    attr_reader :auth_cookie, :channels, :config

    def initialize(config: Config.new)
      @auth_cookie = nil
      @channels    = []
      @config      = config
      @graphs      = []
      @logged_in   = false
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

    def graphs
      if self.logged_in?
        r = self.scry('graph-store', '/keys')
        if r[:body]
          body = JSON.parse r[:body]
          body["graph-update"]["keys"].each do |k|
            @graphs << Graph.new(k["name"], k["ship"])
          end
        end
      end
      @graphs
    end

    def login
      return self if logged_in?

      ensure_connections_closed
      response = Faraday.post(login_url, "password=#{config.code}")
      parse_cookie(response)
      self
    end

    def name
      config.name
    end

    def untilded_name
      name.gsub('~', '')
    end

    def pat_p
      config.name
    end

    def open_channels
      @channels.select {|c| c.open?}
    end

    def scry(app, path, mark = 'json')
      self.login
      scry_url = "#{self.config.api_base_url}/~/scry/#{app}#{path}.#{mark}"

      response = Faraday.get(scry_url) do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = self.cookie
      end

      {status: response.status, code: response.reason_phrase, body: response.body}
    end

    def spider(mark_in, mark_out, thread, data)
      self.login
      url = "#{self.config.api_base_url}/spider/#{mark_in}/#{thread}/#{mark_out}.json"

      response = Faraday.post(url) do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = self.cookie
        req.body = data
      end

      {status: response.status, code: response.reason_phrase, body: response.body}
    end

    #
    # Subscribe to an app at a path.
    # Returns a Receiver which will begin to get back a stream of facts... which is a... Dictionary? Encyclopedia?
    #
    def subscribe(app, path)
      self.login
      (c = Channel.new self, self.make_channel_name).open("Creating a Subscription Channel.")
      self.channels << c
      c.subscribe(app, path)
    end

    def to_s
      "a Ship(name: '#{self.pat_p}', host: '#{self.config.host}', port: '#{self.config.port}')"
    end

    private

    def make_channel_name
      "Channel-#{self.open_channels.count}"
    end

    def ensure_connections_closed
      # Make sure all our created channels are closed by the GC
      ObjectSpace.define_finalizer( self, self.class.finalize(channels) )
    end

    def login_url
      "#{config.api_base_url}/~/login"
    end

    def parse_cookie(resp)
      cookie = resp.headers['set-cookie']
      return unless cookie

      @auth_cookie, @path, @max_age = cookie.split(';')
      self.logged_in = true if @auth_cookie
    end
  end
end
