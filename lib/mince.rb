# = Mince
#
# Mince is focused to provide support to write database agnostic applications
# and to write applications with an architecture that follows the Single
# Responsibility principle.
#
# The highest level difference between using mince and using something
# like Rails' ActiveRecord library is that mince does not encourage 
# the "Active Record Pattern" in general.  Look "Active Record Pattern"
# up in wikipedia to get a good understanding of what that means.
#
# Mince encourages separating your data objects and behavior from your
# business objects and behavior.  These are two separate classes of 
# objects with two complete separate responsibilities.
#
# * The data object provides access to the data store for a particular 
#   collection of data.
# * The business object adds behavior to the data object in order for the 
#   application to provide business value
#
# Creating an architecture like this provides more flexibility and more
# extensibility for your application.  While you are developing your application
# you shoud be asking, what is the responsibility of this object? And make clear
# separations of behavior and responsibility
#
# Given that being said.  The standard way to structure your directories while
# using mince is the following
#
#   ./app
#     ./models
#       - authenticator.rb
#       - user.rb
#       - project.rb
#     ./data_models
#       - user_data_model.rb
#       - project_data_model.rb
#
# 1. `Authenticator` is a standard ruby class that uses the user class
#    to provide strong and clean authentication.
# 2. `User` and `Project` are ruby classes with the Mince::Model mixed in to
#    provide some standard behavior to interact with a mince data model.
# 3. `UserDataModel` and `ProjectDataModel` are classes with the Mince::DataModel 
#    mixed in to provide standard behavior to interact with a mince data interface.
#
# A quick example of the extensibility of this would be if you needed to get users
# from LDAP or Active Directory rather than from MongoDB. This is a pretty common
# request and similar to other requirements for enterprise applications.
#
# With this architecture you could easily expand it to the following:
#
#   ./app
#     ./models
#       - authenticator.rb
#       - user.rb
#       - project.rb
#     ./data_models
#       - ldap_user_data_model.rb
#       - project_data_model.rb
#
# The only difference is now, instead of using a mince user data model, you are using
# a custom ldap user data model.  As long as the API you wrote for the ldap user data
# model requires the same input and provides the same output as the mince user data
# model, then you did not have to change any other code in your application.
#
# Let's take this a little further. Say you have LDAP auth now, and you've continued
# developing on your application.  You start feeling some pain with having your 
# development environment depend on so many external systems in order to be up and
# running.  Think about it, right now you are dependent on MongoDB and a deve LDAP
# environment to be running and seeded with data. That was the position I was in
# and one of the reasons I wrote mince.
#
# Let's extend the architecture like so:
#
#   - app/
#     - models/
#       - authenticator.rb
#       - user.rb
#       - user_data_provider.rb
#       - project.rb
#     ./data_models
#       - ldap_user_data_model.rb
#       - user_data_model.rb
#       - project_data_model.rb
#
# I added a user data model and user data provider.  The user data provider determines
# which user data source to use for the specific environment that you are in.
#
# If you are running in a development environment, then you would configure it to
# use the user data model, if you are in staging, or production environments, you
# would use the ldap user data model.
#
# This removes one external system dependency from our development environment, let's 
# remove MongoDB from being a development dependency as well so that we can focus
# on the business logic of our application, and not waste time on database maintenance
# issues.
#
# Configure mince to use hashy_db when you are running in Development mode like so:
#   # require mince, if you haven't already
#   require 'mince'
#
#   # require the gem (needs to be installed via `gem install`, bundler, gemspec, 
#   # or some other way)
#   require 'hashy_db'
#
#   # Tell mince to use hashy_db
#   Mince::Config.interface = Mince::HashyDb::Interface
#
# Now, all of mince related data interactions will use an in-memory hash.
#
# Configure mince to use mingo (a mince MongoDB interface) when you are running in Staging, or Production mode:
#   # require mince, if you haven't already
#   require 'mince'
#
#   # require the gem (needs to be installed via `gem install`, bundler, gemspec, 
#   # or some other way)
#   require 'mingo'
#
#   # Tell mince to use mingo
#   Mince::Config.interface = Mince::Mingo::Interface
#
# Done. Now we can simply start the ruby server and develop away.
#
# @author Matt Simpson
module Mince
  # Load all mince libraries
  require_relative 'mince/version'
  require_relative 'mince/config'
  require_relative 'mince/data_model'
  require_relative 'mince/model'
end
