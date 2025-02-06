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

[read more ...](https://github.com/DFE-Digital/rails-template?tab=readme-ov-file#tools-optionally-installed-by-asdf)

Refer to `.ruby-version` in the root of the project for the version of Ruby
currently used.

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
