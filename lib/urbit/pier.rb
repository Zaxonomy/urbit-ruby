require 'faraday'

module Urbit
  module Api

    class Pier
      def initialize
        @c = Config.new
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
        response = Faraday.post('http://localhost:8080/~/login', "password=#{@c.pier_code}")
        @logged_in = parse_cookie response
      end

      def parse_cookie(resp)
        if cookie = resp.headers['set-cookie']
          @urbauth, @path, @max_age = cookie.split(';')
          @logged_in = true if @urbauth
        end
        @logged_in
      end

      def pat_p
        @c.pier_name
      end
    end

  end
end
