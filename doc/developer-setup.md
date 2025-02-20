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

Refer to `.tool-versions` in the root of the project for the version of Ruby
currently used.

## Install Postgres

brew install postgresql@14

## Install dfe-frontend

Refer to the following links for the latest documentation and version of the 'dfe-frontend'.
Run the following commend at the root of the project directory.

https://design.education.gov.uk/design-system/dfe-frontend
https://www.npmjs.com/package/dfe-frontend

```
$ npm i dfe-frontend
```
Ensure that the folders: /node_modules/dfe-frontend and  /node_modules/govuk-frontend are created

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

## The following take tasts are also run as part of the assets:precompile task

This ensures to not slow down Rails startup and runs only when assets are precompiled (e.g., during deployment).

```
lib/tasks/dfe_frontend_images.rake
```

This rake task copies images from external (/node_modules) frontend packages (DfE & GOV.UK Frontend)
into the Rails app's  assets directory. This ensures that the images are available
for use in the application, especially in production where asset pipelines are used.

## Start the application

Navigate to [https://localhost:3000/](https://localhost:3000/)
