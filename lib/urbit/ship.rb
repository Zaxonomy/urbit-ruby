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

    #
    # Answers a collection of all the top-level graphs on this ship.
    # This collection is cached and will need to be invalidated to discover new graphs.
    #
    def graphs(flush_cache = false)
      @graphs = [] if flush_cache
      if @graphs.empty?
        if self.logged_in?
          r = self.scry('graph-store', '/keys')
          if r[:body]
            body = JSON.parse r[:body]
            body["graph-update"]["keys"].each do |k|
              @graphs << Graph.new(self, k["name"], k["ship"])
            end
          end
        end
      end
      @graphs
    end

    #
    # A helper method to just print out the descriptive names of all the ship's graphs.
    def graph_names
      self.graphs.collect {|g| g.to_s}
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

    def remove_graph(a_graph)
      delete_json = %Q({
        "delete": {
          "resource": {
            "ship": "#{self.name}",
            "name": "#{a_graph.name}"
          }
        }
      })

      spider = self.spider('graph-view-action', 'json', 'graph-delete', delete_json, "NO_RESPONSE")
      if (retcode = (200 == spider[:status]))
        self.graphs.delete a_graph
      end
      retcode
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

    #
    # Poke an app with a message using a mark.
    #
    # Returns a Channel which has been created and opened and will begin
    #   to get back a stream of facts via its Receiver.
    #
    def poke(app, mark, message)
      (self.add_channel).poke(app, mark, message)
    end

    def scry(app, path, mark = 'json')
      self.login
      mark = ".#{mark}" unless mark.empty?
      scry_url = "#{self.config.api_base_url}/~/scry/#{app}#{path}#{mark}"

      response = Faraday.get(scry_url) do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = self.cookie
      end

      {status: response.status, code: response.reason_phrase, body: response.body}
    end

    def spider(mark_in, mark_out, thread, data, *args)
      self.login
      url = "#{self.config.api_base_url}/spider/#{mark_in}/#{thread}/#{mark_out}.json"

      # TODO: This is a huge hack due to the fact that certain spider operations are known to
      #       not return when they should. Instead I just set the timeout low and catch the
      #       error and act like everything is ok.
      if args.include?("NO_RESPONSE")
        conn = Faraday::Connection.new()
        conn.options.timeout = 1
        conn.options.open_timeout = 1

        begin
          response = conn.post(url) do |req|
            req.headers['Accept'] = 'application/json'
            req.headers['Cookie'] = self.cookie
            req.body = data
          end
        rescue Faraday::TimeoutError
          return {status: 200, code: "ok", body: "null"}
        end
      end

      response = Faraday.post(url) do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = self.cookie
        req.body = data
      end

      {status: response.status, code: response.reason_phrase, body: response.body}
    end

    #
    # Subscribe to an app at a path.
    #
    # Returns a Channel which has been created and opened and will begin
    #   to get back a stream of facts via its Receiver.
    #
    def subscribe(app, path)
      (self.add_channel).subscribe(app, path)
    end

    def to_s
      "a Ship(name: '#{self.pat_p}', host: '#{self.config.host}', port: '#{self.config.port}')"
    end

    private

    def add_channel
      self.login
      (c = Channel.new self, self.make_channel_name)
      self.channels << c
      c
    end

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
