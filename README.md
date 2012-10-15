# RelevanceRails

Rails application generator built on [AppScrolls](http://appscrolls.org/).
Ships with a stack of opinionated scrolls to run by default.

## Installation

Add this line to your application's Gemfile:

    gem install relevance_rails


## Usage

### Listing Available Scrolls

    relevance_rails scrolls

### Viewing the Compiled Template

    relevance_rails new my_app --dry_run

### Generating a Rails App

    relevance_rails new my_app

## Development

### Running the test suite

    bundle install
    rake spec

### Running the local binary

    bundle exec bin/relevance_rails

### Installing the Gem locally

    rake install

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
