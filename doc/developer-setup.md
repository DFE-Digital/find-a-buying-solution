# Setting up a development environment

## Install Dependencies

The following instructions are written with Mac OS users in mind, please seek
alternative documentation for Linux or Windows users.

### Ruby

You can use either  [rbenv](https://rbenv.org/) or [RVM](https://rvm.io/) or [asdf](https://github.com/asdf-vm/asdf)
with the [asdf-ruby plugin](https://github.com/asdf-vm/asdf-ruby) to install
Ruby. Both will work; **asdf** has an advantage in allowing you to manage
versions of a wide range of tools (NodeJS, Python, etc.) via a single,
consistent interface.

Refer to `.ruby-version` in the root of the project for the version of Ruby
currently used.

## Installing using rbenv

```
$ brew install rbenv ruby-build

## Add this to your .zshrc file:
$ echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc

## Reload your shell:
$ source ~/.zshrc

## If you use bash, add this to your .bash_profile:
$ echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile

## Reload your shell:
$ source ~/.bash_profile

## Do this after installing rbenv
$ rbenv install  3.4.1

## Ensure Ruby Version is Set Correctly
## Run the following command to confirm that rbenv is using the desired version of Ruby ( 3.4.1):

## The output should indicate ruby  3.4.1. If not, set the Ruby version globally (or locally) with:
$ rbenv global  3.4.1

## Or for a specific project directory:
$ rbenv local  3.4.1

## After setting the Ruby version, rehash rbenv to ensure everything works correctly:
$ rbenv rehash
```
 
## Install Postgres

brew install postgresql@14

## Initialise the application

```
$ gem install bundler
$ bundle install
```

## Set up the database and seed the local environment:

```
$ bundle exec rails db:setup
```

## Precompile the assets:

```
$ bundle exec rails assets:precompile
```

## Start the application

Navigate to [https://localhost:3000/](https://localhost:3000/)
