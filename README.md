# Urbit::Api
## The Ruby interface to the Urbit HTTP API

This library wraps the Urbit ship http interface exposing it as a Ruby gem.

[![awesome urbit badge](https://img.shields.io/badge/~-awesome%20urbit-lightgrey)](https://github.com/urbit/awesome-urbit)

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
# => #<Urbit::Ship:0x00007fa74b87f920 ...

OR... with config file...
> ship = Urbit.connect(config_file: '_config-barsyr-latreb.yml')

> ship.logged_in?
# => false

> ship.login
# => #<Urbit::Ship:0x00007fa74b87f920 ...

> ship.logged_in?
# => true

> ship.to_s
# => "a Ship(name: '~barsyr-latreb', host: 'http://localhost', port: '8080')"

> channel = ship.subscribe('graph-store', '/updates')
# => a Channel (Open) on ~barsyr-latreb(name: 'Channel-0', key: '1622836437b540b4')

# Subscribing works by opening a Channel. Your ships has a collection of all it's open Channels.
> channel = ship.open_channels.first
# => a Channel (Open) on ~barsyr-latreb(name: 'Channel-0', key: '1622836437b540b4') ... [it's the same one.]

# Every Channel has a unique key to identify it.
> channel.key
# => "16142890875c348d"

# The Channel has a Receiver that will now be listening on the app and path you specified. Each time an event is sent in it will be stored in the receiver's facts collection.
> channel.receiver.facts.count
=> 12

> channel.receiver.facts.last
=> {:message=>
     {"json"=>
       {"graph-update"=>
         {"add-nodes"=>
           {"resource"=>{"name"=>"test0-996", "ship"=>"barsyr-latreb"},
            "nodes"=>
             {"/170141184504954066298369929365830487769"=>
               {"post"=>
                 {"index"=>"/170141184504954066298369929365830487769",
                  "author"=>"barsyr-latreb",
                  "time-sent"=>1615564146267,
                  "signatures"=>[],
                  "contents"=>[],
                  "hash"=>"0x92b0.c976.58f0.3035.c126.64a0.3043.b962"},
                "children"=>
                 {"2"=>
                   {"post"=>
                     {"index"=>"/170141184504954066298369929365830487769/2",
                      "author"=>"barsyr-latreb",
                      "time-sent"=>1615564146267,
                      "signatures"=>[],
                      "contents"=>[],
                      "hash"=>"0x2ffe.3ca7.20eb.11af.51f8.fbab.2b88.9f48"},
                    "children"=>nil},
                  "1"=>
                   {"post"=>
                     {"index"=>"/170141184504954066298369929365830487769/1",
                      "author"=>"barsyr-latreb",
                      "time-sent"=>1615564146267,
                      "signatures"=>[],
                      "contents"=>[],
                      "hash"=>"0x2ffe.3ca7.20eb.11af.51f8.fbab.2b88.9f48"},
                    "children"=>
                     {"1"=>
                       {"post"=>
                         {"index"=>"/170141184504954066298369929365830487769/1/1",
                          "author"=>"barsyr-latreb",
                          "time-sent"=>1615564146267,
                          "signatures"=>[],
                          "contents"=>[{"text"=>"Test 0.8"}, {"text"=>"Test 0.8"}],
                          "hash"=>"0x9516.25fc.ca7a.5bb9.356b.2fce.b29a.f372"},
                        "children"=>nil}}}}}}}}},
      "id"=>2,
      "response"=>"diff"
    }
  }

#  Your ship keeps a collection of all the messages sent to urbit:
> channel.sent_messages.collect {|m| m.to_s}
=> [
    "a Message({:action=>"poke", :app=>"hood", :id=>1, :json=>"Opening Airlock", :mark=>"helm-hi", :ship=>"barsyr-latreb"})",
    "a Message({:action=>"subscribe", :app=>"graph-store", :id=>2, :path=>"/updates", :ship=>"barsyr-latreb"})",
    "a Message({"id"=>3, "action"=>"ack", "event-id"=>"0"})",
    "a Message({"id"=>4, "action"=>"ack", "event-id"=>"1"})",
    "a Message({"id"=>5, "action"=>"ack", "event-id"=>"2"})"
   ]

# Retrieving your ship's base hash using scry....
> ship.scry('file-server', '/clay/base/hash')
# => {:status=>200, :code=>"ok", :body=>"\"e75k5\""}

# Creating a new Notebook in "My Channels" using %spider....
> create_json = %Q(
        {"create": {"resource": { "ship": "~zod", "name": "random_name"},
        "title": "Testing",
        "description": "Testing Un-Managed Graph Creation",
        "associated" : {"policy": {"invite": {"pending": []}}},
        "module": "publish", "mark": "graph-validator-publish"}}
  )
> ship.spider('graph-view-action', 'json', 'graph-create', create_json)
# => {:status=>200, :code=>"ok", :body=>"\"e75k5\""}

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
### ~zod

Tests assume that an instance of a ["fake" development Urbit ship](https://urbit.org/using/develop/) (one not connected to the live network) will be running, available at `http://localhost:8080`.

To create a development ship:
```sh
./urbit -F zod
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/urbit-api.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
