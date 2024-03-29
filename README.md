# Urbit::Api

## The Ruby interface to the Urbit HTTP API

This library wraps the Urbit ship http interface exposing it as a Ruby gem.

[![awesome urbit badge](https://img.shields.io/badge/~-awesome%20urbit-lightgrey)](https://github.com/urbit/awesome-urbit)
[![Gem Version](https://badge.fury.io/rb/urbit-api.svg)](https://badge.fury.io/rb/urbit-api)
[![License](https://img.shields.io/github/license/Zaxonomy/urbit-ruby)](https://github.com/Zaxonomy/urbit-ruby/blob/master/LICENSE.txt)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'urbit-api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install urbit-api

## Usage

```sh
> bin/console

# This will instantiate a ship that connects to the fake `~zod` dev server by default
# See Urbit docs for more info: https://urbit.org/using/develop/
[1] pry(main)> ship = Urbit.new
=> #<Urbit::Ship:0x00007fa74b87f920 ...

OR... with config file...
> ship = Urbit.connect(config_file: '_config-barsyr-latreb.yml')

> ship.logged_in?
=> false

> ship.login
=> #<Urbit::Ship:0x00007fa74b87f920 ...

> ship.logged_in?
=> true

> ship.to_s
=> "a Ship(name: '~barsyr-latreb', host: 'http://localhost', port: '8080')"

> channel = ship.subscribe(app: 'graph-store', path: '/updates')
=> a Channel (Open) on ~barsyr-latreb(name: 'Channel-0', key: '1622836437b540b4')

# Subscribing works by opening a Channel. Your ships has a collection of all it's open Channels.
> channel = ship.open_channels.first
=> a Channel (Open) on ~barsyr-latreb(name: 'Channel-0', key: '1622836437b540b4')

# Notice that it's the same one.

# Every Channel has a unique key to identify it.
> channel.key
=> "16142890875c348d"

# The Channel has a Receiver that will now be listening on the app and path you specified. Each time an event is sent in it will be stored in the receiver's facts collection.
> channel.receiver.facts.count
=> 12

# Perform any action through landscape that would initiate an update into %graph-store...
# In this case I have added a comment to a local notebook.
> channel.receiver.facts.last
=> a Fact({:ship=>{:name=>"~barsyr-latreb", :host=>"http://localhost", :port=>"8080"}, :resource=>"~barsyr-latreb/test0-996", :acknowleged=>true, :is_graph_update=>true})

#  Your ship keeps a collection of all the messages sent to urbit:
> channel.sent_messages.collect {|m| m.to_s}
=> [
    "a Message({:action=>"poke", :app=>"hood", :id=>1, :json=>"Opening Airlock", :mark=>"helm-hi", :ship=>"barsyr-latreb"})",
    "a Message({:action=>"subscribe", :app=>"graph-store", :id=>2, :path=>"/updates", :ship=>"barsyr-latreb"})",
    "a Message({"id"=>3, "action"=>"ack", "event-id"=>"0"})",
    "a Message({"id"=>4, "action"=>"ack", "event-id"=>"1"})",
    "a Message({"id"=>5, "action"=>"ack", "event-id"=>"2"})"
   ]

#
# --------------------------------------------------------------------
# Poke
# --------------------------------------------------------------------
#
> ship.poke(app: 'hood', mark: 'helm-hi', message: 'Opening Airlock')
=> a Channel (Open) on ~barsyr-latreb(name: 'Channel-0', key: '1630355920a717e1')

#
# --------------------------------------------------------------------
# Scry
# --------------------------------------------------------------------
#
# Retrieving your ship's base hash using scry....
> ship.scry(app: 'file-server', path: '/clay/base/hash')
# => {:status=>200, :code=>"ok", :body=>"\"e75k5\""}

#
# --------------------------------------------------------------------
# Spider
# --------------------------------------------------------------------
#
# Creating a new Notebook in "My Channels" using %spider....
> create_json = %Q(
        {"create": {"resource": { "ship": "~zod", "name": "random_name"},
        "title": "Testing",
        "description": "Testing Un-Managed Graph Creation",
        "associated" : {"policy": {"invite": {"pending": []}}},
        "module": "publish", "mark": "graph-validator-publish"}}
  )
> ship.spider(mark_in: 'graph-view-action', mark_out: 'json', thread: 'graph-create', data: create_json)
# => {:status=>200, :code=>"ok", :body=>"\"e75k5\""}

#
# --------------------------------------------------------------------
# %graph-store
# --------------------------------------------------------------------
#
> puts ship.graph_names
~barsyr-latreb/dm-inbox
~darlur/announce
~bitbet-bolbel/urbit-community-5.963
~winter-paches/top-shelf-6391
~winter-paches/the-great-north-7.579
~barsyr-latreb/test0-996
~fabled-faster/test-chat-a-5919
~barsyr-latreb/test1-4287
~darrux-landes/welcome-to-urbit-community
~millyt-dorsen/finance-2.962
~fabled-faster/interface-testing-facility-683
~darlur/help-desk-4556
=>

# Reference a graph by name and return a single node.
> puts ship.graph(resource: '~winter-paches/top-shelf-6391').node(index: "170.141.184.505.207.751.870.046.689.877.378.990.080")
a Node({:index=>"170.141.184.505.207.751.870.046.689.877.378.990.080", :author=>"witfyl-ravped", :contents=>[{"text"=>"the patches don't really bother me though tbh"}], :time_sent=>1629316468195, :is_parent=>false, :child_count=>0})
=>

# You can also reference a graph by its index in the graphs collection.
> puts ship.graphs[3].node(index: "170.141.184.505.207.751.870.046.689.877.378.990.080")
a Node({:index=>"170.141.184.505.207.751.870.046.689.877.378.990.080", :author=>"witfyl-ravped", :contents=>[{"text"=>"the patches don't really bother me though tbh"}], :time_sent=>1629316468195, :is_parent=>false, :child_count=>0})
=>

# Return the contents of the 5 oldest nodes of a graph
> graph = ship.graph(resource: '~winter-paches/top-shelf-6391')
> graph.oldest_nodes(count: 5).sort.each {|n| p n.contents};nil
[{"text"=>"watching the 2020 stanley cup finals (tampa (sigh) just went up 2-0 in game 3) and i thought: \"the great north has to have a hockey chat, eh?\""}]
[{"text"=>"we'll see if this has legs. ;)"}]
[{"text"=>"shortie! now 2-1 tampa."}]
[{"text"=>"looks like tampa's going to go up 2-1. as a canadian this geographically depresses me. :/"}]
[{"text"=>"anyone in the stands?"}]
=>

# A single Node. In this case, the 3rd oldest node in the graph.
> puts graph.nodes[2].contents
{"text"=>"shortie! now 2-1 tampa."}
=>

# Getting the next newer Node. Remember that it always returns an Array, hence the '#first'.
> puts graph.nodes[2].next.first.contents
{"text"=>"looks like tampa's going to go up 2-1. as a canadian this geographically depresses me. :/"}
=>

# Return the indexes of the newest 5 nodes of a graph
> ship.graph(resource: '~winter-paches/top-shelf-6391').newest_nodes(count: 5).sort.each {|n| p n.index};nil
"170.141.184.505.209.257.330.601.508.862.548.770.816"
"170.141.184.505.209.375.247.350.471.711.992.578.048"
"170.141.184.505.209.545.972.004.310.065.795.301.376"
"170.141.184.505.209.627.337.970.761.265.544.429.568"
"170.141.184.505.209.644.102.846.398.558.514.446.336"
=>

# Fetching nodes older relative to another node. (See indexes above)
> puts (node = ship.graph(resource: '~winter-paches/top-shelf-6391').node(index: "170.141.184.505.209.644.102.846.398.558.514.446.336"))
a Node({:index=>"170.141.184.505.209.644.102.846.398.558.514.446.336", :author=>"winter-paches", :contents=>[{"text"=>"yep. that's how i did it as a kid. harry caray was the white sox announcer before he turned traitor and went to the cubs."}], :time_sent=>1629419046028, :is_parent=>false, :child_count=>0})
=>

> puts node.previous
a Node({:index=>"170.141.184.505.209.627.337.970.761.265.544.429.568", :author=>"pathus-hiddyn", :contents=>[{"text"=>"Lol oh man I haven’t listened to a baseball game on the radio in forever. It is great isn’t it. "}], :time_sent=>1629418137668, :is_parent=>false, :child_count=>0})
=>

> node.previous(count: 4).each {|n| p n.index};nil
"170.141.184.505.209.257.330.601.508.862.548.770.816"
"170.141.184.505.209.375.247.350.471.711.992.578.048"
"170.141.184.505.209.545.972.004.310.065.795.301.376"
"170.141.184.505.209.627.337.970.761.265.544.429.568"

# Creating a Document New Post in a Publish Graph
> graph = ship.graph(resource: '~barsyr-latreb/NPG')
=> a Graph(~barsyr-latreb/NPG)

> graph.type
=> publish

> graph = graph.molt                     # This is necessary for now since a Graph initially doesn't know it's type.
=> a PublishGraph(~barsyr-latreb/NPG)

> graph.add_post(author: '~barsyr-latreb', title: 'Titleist', body: 'What a body!')
=> true

#
# --------------------------------------------------------------------
# %group-store
# --------------------------------------------------------------------
#
# Show the paths of all your current Groups
> ship.groups.list
=> Hammock Coast
The Darlur System
The Great North

# Leave the highlighted Group above
> group = ship.groups[title: 'Hammock Coast']
=> a Group({:title=>"Hammock Coast", :description=>"Martians living in God's Country: Coastal South Carolina between Georgetown and Myrtle Beach", :host=>"~darlur", :key=>"hammock-coast", :member_count=>3, :pending_invites=>"?", :hidden=>false})

> group.leave
=> {:status=>200, :code=>"ok", :body=>"null"}

# The Group is no longer in your list of Groups
> ship.groups.list
=> The Darlur System
The Great North

# (Re-) Join the Group
> ship.groups.join(host: "~darlur", name: "hammock-coast")

# A group knows about it's Graphs
> group = ship.groups[title: 'Hammock Coast']
=> a Group({:title=>"Hammock Coast", :description=>"Martians living in God's Country: Coastal South Carolina between Georgetown and Myrtle Beach", :host=>"~darlur", :key=>"hammock-coast", :member_count=>3, :pending_invites=>"?", :hidden=>false})

> group.graphs.map {|g| g.name}
=> ["the-beach-2315"]

> group.graphs.map {|g| g.title}
=> ["The Beach"]

# The group is now back in your list of Groups (With large groups this may take a moment)
> ship.groups.list
=> Hammock Coast
The Darlur System
The Great North

# Create a new group
> ship.groups.create(name: 'group-4', title: 'Fourth Group', description: "4th Group")

> ship.groups.list
=> Fourth Group
Hammock Coast
The Darlur System
The Great North

# Send out an invitation to your new group
> group = ship.groups[path: '~barsyr-latreb/group-4']
=> a Group({:host=>"~barsyr-latreb", :key=>"group-4", :member_count=>0, :pending_invites=>"?", :hidden=>false})

> group.invite(ship_names: ['~winter-paches'], message: 'hello!')
=> {:status=>200, :code=>"ok", :body=>"null"}

# Archive your new group
> group.delete
=> {:status=>200, :code=>"ok", :body=>"null"}

#
# --------------------------------------------------------------------
# %settings-store
# --------------------------------------------------------------------
#
# Show all your ship's settings as a list of {desk: , bucket:}
> ship.settings.list
desk: landscape
  buckets: ["calm: 5 entries", "display: 2 entries", "urbit-visor-permissions: 1 entries"]
desk: bitcoin
  buckets: ["btc-wallet: 2 entries"]
=>

# Behind the scenes your ship has now done the following to retrieve the settings
# and we are now also listening for changes in any settings on the ship...
> ship.subscribe(app: 'settings-store', path: '/all')

# Settings for a single desk
> ship.settings[desk: 'landscape']
=> a Setting({:desk=>"landscape", :buckets=>#<Set: {#<Urbit::Bucket:0x00007fa6c99aa7a0 @name="calm", @entries={"hideUtilities"=>false, "hideGroups"=>false, "hideAvatars"=>true, "hideUnreads"=>false, "hideNicknames"=>true}>, #<Urbit::Bucket:0x00007fa6c99aa6b0 @name="display", @entries={"backgroundType"=>"color", "background"=>"0xa8.90ea"}>, #<Urbit::Bucket:0x00007fa6c99aa638 @name="urbit-visor-permissions", @entries={"https://urbitdashboard.com"=>["shipName", "shipURL", "scry", "subscribe", "poke", "thread"]}>}>})

> ship.settings[desk: 'landscape'].entries(bucket: 'calm')
=> {"hideUtilities"=>false, "hideGroups"=>true, "hideAvatars"=>true, "hideUnreads"=>false, "hideNicknames"=>true}

# Go to Landscape and toggle the "Hide Groups" button inside the Calm Engine settings page...
> ship.settings[desk: 'landscape'].entries(bucket: 'calm')
=> {"hideUtilities"=>false, "hideGroups"=>false, "hideAvatars"=>true, "hideUnreads"=>false, "hideNicknames"=>true}

# Alternatively you can directly access the bucket instance using this syntax:
)> ship.settings[desk: 'landscape'][bucket: 'calm']
=> a Bucket({:name=>"calm", :entries=>{"hideUtilities"=>false, "hideGroups"=>false, "hideAvatars"=>true, "hideUnreads"=>false, "hideNicknames"=>true}})

# Then you can also set them yourself if you like.
> ship.settings[desk: 'landscape'][bucket: 'calm'][key: 'hideGroups'] = true

# Your Group tiles will now disappear. And:
> ship.settings[desk: 'landscape'][bucket: 'calm']
=> a Bucket({:name=>"calm", :entries=>{"hideUtilities"=>false, "hideGroups"=>true, "hideavatars"=>true, "hideUnreads"=>false, "hideNicknames"=>true}})

# You can add a new Bucket to a Desk.
> ship.settings[desk: 'landscape'].add_bucket(name: 'mars-base-10', entries: {"current_pane" => 1, "current-view" => "graph-rover"})
=>

> ship.settings.list
desk: garden
  buckets: ["tiles: 1 entries"]
desk: landscape
  buckets: ["calm: 5 entries", "display: 2 entries", "urbit-visor-permissions: 1 entries", "mars-base-10: 2 entries"]
desk: bitcoin
  buckets: ["btc-wallet: 2 entries"]
=>

# And remove an entry...
> ship.settings[desk: 'landscape'][bucket: 'mars-base-10'].remove_entry(key: 'current_view')
=>

# And remove it entirely if you change your mind.
> ship.settings[desk: 'landscape'].remove_bucket(name: 'mars-base-10')
=>


```
### Configuration

Configure your ship using a config file or constructor keyword arguments. Either or both can be used; the keyword args will override any values set via config file.

Supported keys:
- `code` - the auth code
- `host` - the ship's host (e.g., 'localhost' or 'myship.net')
- `name` - the ship's name (e.g, '~zod')
- `port` - the open www port on your ship ('80' by default)

#### Config File

See [`_config.yml`](_config.yml) for an example config file. This will connect to a local fake zod, see creation instructions below.

```rb
ship = Urbit.new(config_file: 'my-moon.yml')
```

#### Constructor Keyword Arguments

```rb
ship = Urbit.new(host: '127.0.0.1', port: '8080')
```

## Testing

```sh
bin/test
```
Tests assume that an instance of a ["fake" development Urbit ship](https://urbit.org/using/develop/) (one not connected to the live network) will be running, available at `http://localhost:8080`.
### "fake" ~zod

To create this development ship:
```sh
./urbit -F zod
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/urbit-api.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
