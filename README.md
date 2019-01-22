# ZplScaler

## Why

Our Zebra printer has a 300dpi resolution, and can only handle ZPL that is to be printed by a 300dpi printer.

Some shipping API are not configurable enough, and can return ZPL code that is to be printed by a 203dpi printer.

We needed a way to scale a ZPL code from 203dpi to 300dpi.


## How it works

It works by parsing the ZPL commands and emitting new commands after scaling some of their arguments if needed.
The parsing is simple and doesn't handle all corner cases like the change of control character (the parser always assume it's `^`).

Here is the list of commands that can be scaled currently:

- `^MN` - Media Tracking
- `^BY` - Bar Code Field Default
- `^FO` - Field Origin
- `^B2` - Interleaved 2 of 5 Bar Code
- `^GB` - Graphic Box
- `^BC` - Code 128 Bar Code (Subsets A, B, and C)
- `^A#` commands, where `#` is a font name (`[A-Z0-9]`) - Scalable/Bitmapped Font

These commands have at least one argument that is a coordinate (in dots) and need to be recalculated (scaled).
The non-coordinate arguments and all other commands not listed above are not touched and left as is.

This gem only handles a few ZPL commands we needed, feel free to send a PR to add support for a ZPL command you need to be scaled.

Note that some commands won't ever be handled correctly, like:
- images that are embedded in the ZPL code won't be scaled
- using fonts that are not supposed to be scaled or cannot be


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
