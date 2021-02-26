# Urbit::Api
## The Ruby interface to the Urbit HTTP API

This library wraps the Urbit ship http interface exposing it as a Ruby gem.

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

```rb
# TODO: fix namespacing :)
require 'urbit/urbit'

# This will instantiate a ship that connects to the fake `~zod` dev server by default
# See Urbit docs for more info: https://urbit.org/using/develop/
ship = Urbit.new
# => #<Urbit::Ship:0x00007fa74b87f920 ...

ship.logged_in?
# => false

ship.login
# => #<Urbit::Ship:0x00007fa74b87f920 ...

ship.logged_in?
# => true

channel = ship.open_channel('my-channel')
# => #<Urbit::Channel:0x00007fa74b291e50 ...

channel.key
# => "16142890875c348d"

ship.channels.first.key
# => "16142890875c348d"

receiver = channel.subscribe(app: 'graph-store', path: '/updates')
# => #<Urbit::Receiver:0x00007fd3928eba58

# This receiver will now be listening on the app and path you specified. Each time an event is sent in it will be stored in the receiver's events collection.
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
