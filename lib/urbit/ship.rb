require 'faraday'

require 'urbit/channel'
require 'urbit/config'
require 'urbit/graph'
require 'urbit/groups'
require 'urbit/links'
require 'urbit/settings'

module Urbit
  class Ship
    attr_accessor :logged_in
    attr_reader :auth_cookie, :channels, :config

    def initialize(config: Config.new)
      @auth_cookie = nil
      @channels    = []
      @config      = config
      @graphs      = []
      @groups      = Groups.new ship: self
      @links       = Links.new
      @settings    = nil                         # Use lazy initialization here
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

    def graph(resource:)
      self.graphs.find {|g| g.resource == resource}
    end

    #
    # Answers a collection of all the top-level graphs on this ship.
    # This collection is cached and will need to be invalidated to discover new graphs.
    #
    def graphs(flush_cache: true)
      @graphs = [] if flush_cache
      if @graphs.empty?
        if self.logged_in?
          r = self.scry(app: 'graph-store', path: '/keys')
          if r[:body]
            body = JSON.parse r[:body]
            body["graph-update"]["keys"].each do |k|
              @graphs << Graph.new(ship: self, graph_name: k["name"], host_ship_name: k["ship"])
            end
          end
        end
      end
      @graphs
    end

    #
    # A helper method to just print out the descriptive names of all the ship's graphs.
    #
    def graph_names
      self.graphs.collect {|g| g.resource}
    end

    #
    # Answers the object managing the Groups on this ship.
    # This object provides all the helper methods to list, join, leave, &c. a Group
    #
    def groups
      @groups
    end

    def links
      @links
    end

    def login
      return self if logged_in?

      ensure_connections_closed
      response = Faraday.post(login_url, "password=#{config.code}")
      parse_cookie(response)
      @groups.load

      # For now we will require a subscription to all metadata. it's the glue between %graphs and %groups.
      # A key issue that arose is that these are both async %subscribe calls and so there are sync issues
      #   if we try to directly link the groups and the graphs. Instead we need to just store the links
      #   and lazy-instatiate the metadata _if_ we have received it.
      @links.load ship: self

      self
    end

    def name
      config.name
    end

    def open_channels
      @channels.select {|c| c.open?}
    end

    def pat_p
      config.name
    end

    #
    # Poke an app with a message using a mark.
    #
    # Returns a Channel which has been created and opened and will begin
    #   to get back a stream of facts via its Receiver.
    #
    def poke(app:, mark:, message:)
      (self.add_channel).poke(app: app, mark: mark, message: message)
    end

    def remove_graph(desk: 'landscape', graph:)
      delete_json = %Q({
        "delete": {
          "resource": {
            "ship": "#{self.name}",
            "name": "#{graph.name}"
          }
        }
      })

      spider = self.spider(desk: desk, mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-delete', data: delete_json, args: ["NO_RESPONSE"])
      if (retcode = (200 == spider[:status]))
        self.graphs.delete graph
      end
      retcode
    end

    def scry(app:, path:, mark: 'json')
      self.login
      mark = ".#{mark}" unless mark.empty?
      scry_url = "#{self.url}/~/scry/#{app}#{path}#{mark}"

      response = Faraday.get(scry_url) do |req|
        req.headers['Accept'] = 'application/json'
        req.headers['Cookie'] = self.cookie
      end

      {status: response.status, code: response.reason_phrase, body: response.body}
    end

    #
    # Answers the object managing the Settings on this ship.
    # This object provides all the helper methods to list, update, and remove a Setting
    #
    def settings
      if self.logged_in?
        @settings = Settings.load(ship: self) if @settings.nil?
      end
      @settings
    end

    def spider(desk: 'landscape', mark_in:, mark_out:, thread:, data:, args: [])
      self.login
      url = "#{self.url}/spider/#{desk}/#{mark_in}/#{thread}/#{mark_out}.json"

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
    def subscribe(app:, path:)
      (self.add_channel).subscribe(app: app, path: path)
    end

    def to_h
      {name: "#{self.pat_p}", host: "#{self.config.host}", port: "#{self.config.port}"}
    end

    def to_s
      "a Ship(#{self.to_h})"
    end

    def untilded_name
      name.gsub('~', '')
    end

    def url
      self.config.api_base_url
    end

    private

    def add_channel
      self.login
      self.channels << (c = Channel.new(ship: self, name: self.make_channel_name))
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
      "#{self.url}/~/login"
    end

    def parse_cookie(resp)
      cookie = resp.headers['set-cookie']
      return unless cookie

      @auth_cookie, @path, @max_age = cookie.split(';')
      self.logged_in = true if @auth_cookie
    end
  end
end
