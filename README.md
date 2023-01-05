[![Build Status](https://travis-ci.org/sul-dlss/sul-directory.svg?branch=master)](https://travis-ci.org/sul-dlss/sul-directory)

# SUL Staff Directory

The SUL Staff Directory is a Rails application that:

 - harvests the Stanford Registry's Org Chart to determine all the departments in the Stanford University Libraries
 - harvests the Stanford LDAP directory to determine all SUL staff
 - fetches the (public) directory information for staff and exposes a common staff directory table

## Requirements

1. Ruby 3.1
2. Bundler
3. A database

## Installation

Clone the repository

    $ git clone git@github.com:sul-dlss/sul-directory.git

Change directories into the app and install dependencies

    $ bundle install

Run database migrations

    $ rake db:migrate

Start the development server

    $ bin/dev

## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/rails_config) settings.yml files.

### Harvesting the org chart

```console
$ bin/rails db:seed
```

## Testing

The test suite (with RuboCop style inforcement) will be run with the default rake task (also run on travis)

    $ bin/rake

The specs can be run without RuboCop enforcement

    $ bin/rake spec

The RuboCop style enforcement can be run without running the tests

    $ bin/rake rubocop
