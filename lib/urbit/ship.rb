require 'faraday'
require 'SecureRandom'

module Urbit
  module Api

    class Ship
      def initialize
        @c = Config.new
        @channels = []
        @logged_in = false
      end

      def cookie
        @urbauth
      end

      def logged_in?
        @logged_in
      end

      def login
        return if logged_in?
        response = Faraday.post('http://localhost:8080/~/login', "password=#{@c.ship_code}")
        @logged_in = parse_cookie response
      end

      def name
        self.pat_p[1..-1]
      end

      def parse_cookie(resp)
        if cookie = resp.headers['set-cookie']
          @urbauth, @path, @max_age = cookie.split(';')
          @logged_in = true if @urbauth
        end
        @logged_in
      end

      def pat_p
        @c.ship_name
      end

      # Opening a channel always creates a new channel which will
      # remain open until this ship is disconnected at which point it
      # will be closed.
      def open_channel(a_name)
        self.login
        c = Channel.new self, a_name
        @channels << c
        c
      end

      def open_channels
        @channels
      end
    end

  end
end
