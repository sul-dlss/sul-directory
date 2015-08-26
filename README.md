[![Build Status](https://travis-ci.org/sul-dlss/sul-directory.svg?branch=master)](https://travis-ci.org/sul-dlss/sul-directory)
[![Coverage Status](https://coveralls.io/repos/sul-dlss/sul-directory/badge.svg)](https://coveralls.io/r/sul-dlss/sul-directory)
[![Dependency Status](https://gemnasium.com/sul-dlss/sul-directory.svg)](https://gemnasium.com/sul-dlss/sul-directory)

# SUL Staff Directory

The SUL Staff Directory is a Rails application that:

 - harvests the Stanford Registry's Org Chart to determine all the departments in the Stanford University Libraries
 - harvests the Stanford LDAP directory to determine all SUL staff
 - fetches the (public) directory information for staff and exposes a common staff directory table

## Requirements

1. Ruby (2.2.1 or greater)
2. Rails (4.2.0 or greater)
3. A database

## Installation

Clone the repository

    $ git clone git@github.com:sul-dlss/sul-directory.git

Change directories into the app and install dependencies

    $ bundle install

Run database migrations

    $ rake db:migrate

Start the development server

    $ rails s

## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/rails_config) settings.yml files.

### Harvesting the org chart

```console
$ rake db:seed
```

## Testing

The test suite (with RuboCop style inforcement) will be run with the default rake task (also run on travis)

    $ rake

The specs can be run without RuboCop enforcement

    $ rake spec

The RuboCop style enforcement can be run without running the tests

    $ rake rubocop