# What is Mince

This library contains the core components to use Mince libraries.

More info on mince to come.

## Config

Use the config class to configure which mince database interface you
desire to use:

```
Mince::Config.interface = Mince::HashyDb::Interface
```

## Test support for developing Mince Database Interfaces

There are a few mince database interface libraries available, in order
to provide a more concrete and uniform contract for the mince APIs among
these libraries, mince provides an Rspec shared example.  

Use this shared example in order to run integration tests against your
mince database interface.

```ruby
# require the mince database interface you are using / developing
require 'hashy_db'

# require the shared example
require_relative 'mince/shared_examples/interface_example'

describe 'The shared example for a mince interface' do
  before do
    # configure the interface
    Mince::Config.interface = Mince::HashyDb::Interface
  end

  # run the shared example
  it_behaves_like 'a mince interface'
end
```

# Dev

## Running specs

One time run:

```
bundle exec rake
```

Guard:

```
bundle exec guard
```

# Contribute

- fork into a topic branch, write specs, make a pull request.

# Owners

Matt Simpson - [@railsgrammer](https://twitter.com/railsgrammer)

