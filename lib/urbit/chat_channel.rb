require 'securerandom'

require 'urbit/message'
require 'urbit/receiver'
require 'urbit/close_message'
require 'urbit/poke_message'
require 'urbit/subscribe_message'

module Urbit
  class ChatChannel < Channel
    # def messages
    #   self.fetch_all_nodes if @nodes.empty?
    #   @nodes
    # end

    # def newest_messages(count = 100)
    #   self.fetch_newest_nodes(count) if @nodes.empty?
    #   self.nodes
    # end

  end
end
