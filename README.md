# ZplScaler - (new name: ZplTransformer)

## Why

Our Zebra printer has a 300dpi resolution, and can only handle ZPL that is to be printed by a 300dpi printer.

Some shipping API are not configurable enough, and can return ZPL code that is to be printed by a 203dpi printer.

We needed a way to scale a ZPL code from 203dpi to 300dpi.


## How it works

It works by parsing the ZPL commands and transform them through one or more transformers.

The ZPL command parser reads commands one by one, ignoring newlines and comments between each command.
NOTE: the parser assumes the control char to be `^`, it doesn't support the command `^CC` to change the control char.

A transformer is a class inheriting from `ZplScaler::Transformer::Base` and implementing the method `map_cmd(cmd)`

TODO explain how a transformer is applied? & how to implem' a Transformer (takes a ZplCommand, and should return a ZplCommand, can return nil to delete a cmd)


## Available transformers

### `ZplScaler::Transformer::GenericScaler`

This transformer can scale to a given ratio, specific arguments of a set of commands.

Example:

```rb
code = '^XA^GB12,30,2,B^XZ',
scaler = ZplScaler::Transformer::GenericScaler.new(1.2) # ratio: 1.2
puts scaler.apply(code) # => "^XA^GB14,36,2,B^XZ"
```

List of commands that can be scaled currently:

- `^MN` - Media Tracking
- `^BY` - Bar Code Field Default
- `^FO` - Field Origin
- `^B2` - Interleaved 2 of 5 Bar Code
- `^GB` - Graphic Box
- `^BC` - Code 128 Bar Code (Subsets A, B, and C)

These commands have at least one argument that is a coordinate (in dots) and need to be recalculated (scaled).
The non-coordinate arguments and all other commands not listed above are not touched and left as is.

This transformer only scales a few ZPL commands we needed, feel free to send a PR to add support for a ZPL command you need to be scaled.

Note: images that are embedded in the ZPL code are not supported.


### `ZplScaler::Transformer::FontScaler`

This transformer can scale font commands (`^A` and `^CF`) to a given ratio.

The ZPL2 specification has two kind of fonts available: scalable and bitmap.
- The scalable fonts don't have a fixed size, they can be easily scaled.
- The bitmap fonts have a fixed base size (e.g: font `A` base `height`/`width` is `9`/`5` dots). They can only be scaled to a multiple of their font's base height/width.
  This transformer implements a special algorithm to try to scale bitmap fonts more precisely, but keep in mind that it is inaccurate compared to a scalable font.

#### What's so special about bitmap fonts

Given the font command `^ACR,9,9`, this will set the font `C` only for the next `^FD` field, with a field orientation `R` (rotated 90°) and a size of `9x9` dots for height and width.
However the resulting font size will not be `9x9` dots as the base size of font `C` is `18x10`. The resulting size will be `18x10` since it must be a multiple of the base size of the font.
Similarly, if the input size is `20x15` the resulting size would be `36x20`.

#### Scaling algorithm for bitmap fonts

1. Normalize the given font height to the font's base height (e.g: size `20` becomes `36`).
2. Find smallest font that can be the same size as the given font (e.g: font `A`'s base size is half of font `C`'s base size: `9x5` vs `18x10`). A smaller font means more result granularity when scaling.
3. Scale the normalized given height to the given ratio.
4. Compute the scaled width from the scaled height based on proportion of new font's base size.
5. Normalize again the scaled sizes to the new font's base sizes.


### `ZplScaler::Transformer::Pipeline`

This transformer allows composition of other transformers. It doesn't do anything on its own and allows you to apply multiple transformers in a row. Each transformer's output cmd is given as the input cmd of the next transformer unless the output is `nil`, in which case the cmd is skipped and following transformers are not called.

Example: This will double the scale of `code`, by first applying the **generic scaler** then the **font scaler**.
```rb
code = '^XA^GB12,30,2,B^AA,9,5^XZ',
pipeline = ZplScaler::Transformer::Pipeline.new([
  ZplScaler::Transformer::GenericScaler.new(2.0),
  ZplScaler::Transformer::FontScaler.new(2.0),
])
pipeline.apply(code) # => "^XA^GB24,60,2,B^AA,18,10^XZ"
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zpl-scaler'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install zpl-scaler
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bew/zpl-scaler.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
