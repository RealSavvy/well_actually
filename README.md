## Installation

Is tested with pure ruby classes and classes that inherit from ActiveRecord::Base, rails >= 4 supported.

Add this line to your application's Gemfile:

```ruby
gem 'well-actually', require: 'well_actually'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install well-actually

## Usage
```ruby
Dog < ActiveRecord::Base
  extend WellActually
  # overwrite or overwrites option can be a symbol or an array of symbol, earlier takes precedence over later
  # attributes must be an array of symbols
  well_actually overwrite: :overwrite, attributes: [:name, :show, :birthday]
end

dog = Dog.new(name: "Radar", breed: "Korgi", age: 10, show: true, birthday: Time.new(2010,1,1))
puts dog.name
=> "Radar"
puts dog.age
=> 10

# Overwrite an overwriteable attribute
dog.overwrite["name"] = "Sadie"
# Can't overwrite an unoverwriteable attribute
dog.overwrite["age"] = 12
dog_actually = dog.well_actually
puts dog_actually.name
=> "Sadie"
puts dog_actually.age
=> 10

#Oringal Object Doesn't Change
puts dog.name
=> "Radar"
puts dog.age
=> 10
```

## Development

After checking out the repo, run `gem install bundle`, then `gem install appraisal `, and run `bin/setup` to install dependencies. Then, run `bundle exec appraisal rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RealSavvy/well_actually.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
