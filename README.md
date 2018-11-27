# ZplScaler

TODO: why?!


TODO: list handled commands (only the commands that manipulate coordinates and that need to be re-calculated, all other commands are ignored and left as is)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zpl-scaler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zpl-scaler

## Usage

**Simple example**:
```rb
require 'zpl-scaler'

# Scale by dpi:
ZplScaler.dpi_scale '^XA^GB12,30,2,B^XZ', from_dpi: 203, to_dpi: 300
# => "^XA^GB17,44,2,B^XZ"

# Scale by ratio:
ZplScaler.ratio_scale '^XA^GB12,30,2,B^XZ', 1.2
# => "^XA^GB14,36,2,B^XZ"
```

**Complete example**:
```rb
require 'zpl-scaler'

zpl_content = File.read("label_at_203dpi.zpl")

puts '-- Unique used commands ----'
p ZplScaler::ZplReader.uniq_commands zpl_content

scaled_zpl = ZplScaler.dpi_scale zpl_content, from_dpi: 203, to_dpi: 300

puts '-- Scaled ZPL --------------'
puts scaled_zpl

File.open("label_at_300dpi.zpl", "w") do |file|
  file.write(scaled_zpl)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bew/zpl-scaler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
