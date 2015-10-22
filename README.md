# MarskalSearch

This Ruby Rails gem allows a robust nested SQL text search. To date is has only been tested on MariaDB/MySQL. 

This search gem can output data in 3 formats:

* ActiveRecord
* jQuery [jqGrid](http://www.trirand.com/blog/)
* jQuery [DataTables](https://www.datatables.net/)
* Refer to [TODO.md](supplimental_documentation/TODO.md) for information of proposed features and fixes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'marskal-search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marskal-search

## Usage

#### Classes  ####
##### class `MarskalSearch`
```
Initialize:
    MarskalSearch.new (p_class, p_search_text, options)

        p_class:  ActiveRecord Model
            examples: User  Contact Book

        p_search: String to search for
                    examples: "admin"  "williams" "poe"

        options:  See Below for a list of configurable options
```

##### Options:
There are a several configurable options for this class. See [Options and Examples](supplimental_documentation/DETAILED_README.md) for a list of options and examples

## Rake tasks
To get a list of available shortcuts for jqgrid and datable filters
```ruby
rake marskal_search:shortcuts
```
Note: A list of shortcuts is also available in this repository at [supplimental_documentation/SHORTCUTS.md](supplimental_documentation/SHORTCUTS.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MarskalGroup/marskal-search.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

