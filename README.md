# What is Mince

Mince is a ruby gem to provide a light weight ORM to persist data to a variety of databases in ruby apps.

The motivation behind this is so your application is not tightly tied to a specific database. As your application grows you may need to upgrade to a different database or pull specific models to a different persistence strategy.

Other ORMs are married to the [Active Record Architecture Pattern](http://en.wikipedia.org/wiki/Active_record_pattern).  Although Mince can be used with the Active Record pattern as well, it is designed to be used in more of a [Multitier Architecture Pattern](http://en.wikipedia.org/wiki/Multitier_architecture), where the data layer is separated from the business logic layer in the application.  

*View the [Why Multitier Architecture?](https://github.com/coffeencoke/mince/wiki/Why-multitier-architecture%3F) page for more discussion*

## Language Dependency

**Currently only compatible with Ruby 1.9+.  Support for Ruby 1.8 to come later.**

# How to use it

This library contains the core components to use Mince [supported database interfaces](https://github.com/coffeencoke/mince/wiki/Existing-interfaces). These interfaces can be interchanged, but in this setup example we will be using [HashyDb](https://github.com/coffeencoke/hashy_db), which is an in-memory ruby hash database.

## Install

Install `mince` and `hashy_db` gems:

```bash
gem install mince hashy_db
```

## Config

Use the config class to configure which mince database interface you
desire to use:

```ruby
require 'mince'
require 'hashy_db'

Mince::Config.interface = Mince::HashyDb::Interface
```

## Use it

```ruby
# Get the interface
interface = Mince::Config.interface

# Add a book
interface.add 'books', title: 'The World In Photographs', publisher: 'National Geographic'

# Get all books
interface.find_all 'books'

# Replace a book where the record's id is 1
# Use the interface's primary_key field because
# some databases use non `id` fields for the primary key
primary_key = interface.primary_key
interface.replace 'books', primary_key => 1, title: 'A World In Photographs', publisher: 'National Geographic'
```

# Deeper Look

The following pages provide a deeper look into Mince

Link | Description
----|-----
[API Docs](http://rdoc.info/github/coffeencoke/mince/update_to_v2/frames) | API docs for Mince
[Existing Interfaces](https://github.com/coffeencoke/mince/wiki/Existing-interfaces) | List of supported database interfaces that can be used with Mince
[Usage with Rails](https://github.com/coffeencoke/mince/wiki/Usage-with-rails) | More information on how to use Mince with Rails
[Fancy Mixins](https://github.com/coffeencoke/mince/wiki/Fancy-mixins) | We've written a few mixins that provide some standard behavior to your models while using Mince
[Development](https://github.com/coffeencoke/mince/wiki/Development) | Help by contributing
[Travis CI](https://travis-ci.org/#!/coffeencoke/mince) | Check out the build status of Mince
[Why Multitier Architecture?](https://github.com/coffeencoke/mince/wiki/Why-multitier-architecture%3F) | Discussion about why to use multi tier architecture as apposed to others, such as Active Record

# Contribute

You can contribute to Mince by doing a number of things.  View the [Development](https://github.com/coffeencoke/mince/wiki/Development) page for more details.

# Owners


# Contributors

Name | Twitter | Github
-----|----|-----
**Matt Simpson** (owner & maintainer) | [@railsgrammer](https://twitter.com/railsgrammer) | [@coffeencoke](https://github.com/coffeencoke/)
Jason Mayer | [@farkerhaiku](https://twitter.com/farkerhaiku) | [@farkerhaiku](https://github.com/farkerhaiku)
Amos King | [@adkron](https://twitter.com/adkron) | [@adkron](https://github.com/adkron)
Ionic Mobile Team | [@asynchrony](https://twitter.com/asynchrony) | [@ionicmobile](https://github.com/ionicmobile)

If you've been missed on this list, let us know by creating an issue or sending one of us a message.