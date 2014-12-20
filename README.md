# Skeptick: Better ImageMagick for Ruby

[![Build Status](https://travis-ci.org/maxim/skeptick.png?branch=master)](https://travis-ci.org/maxim/skeptick)
[![Code Climate](https://codeclimate.com/github/maxim/skeptick.png)](https://codeclimate.com/github/maxim/skeptick)
[![Dependency Status](https://gemnasium.com/maxim/skeptick.png)](https://gemnasium.com/maxim/skeptick)

Skeptick is an all-purpose DSL for building and running ImageMagick commands.
It helps you build any transformations, from trivial resizes to complex mask
algorithms and free drawing. In a nutshell, Skeptick is nothing more than a
string manipulator and a process spawner. That's all it's meant to be. However,
with Skeptick you get quite a few advantages over using plain shell-out or other
libraries.

## What you get

* Clean Ruby syntax to build ImageMagick commands
* Composable Image objects
* ImageMagick's `STDERR` output revealed in a Ruby exception
* Ability to save intermediate images for debugging
* Minimal memory consumption on shell-outs thanks to
[posix-spawn](https://github.com/rtomayko/posix-spawn)
* Emphasis on performing the whole transformation in a single command

## Installation

Add this line to your application's Gemfile:

    gem 'skeptick'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skeptick

## Usage

To use Skeptick, you simply require it and include the module into your class.

```ruby
require 'skeptick'

class MyClass
  include Skeptick

  def convert_some_image
    cmd = convert(to: 'result.png') do
      # ...
    end

    cmd.run
  end
end
```

The `cmd` object seen in above example can be inspected to see the exact command
that Skeptick will run. Simply use `cmd.inspect` or `cmd.to_s`. Skeptick never
runs anything until you call `run` (except for one very special case), so you
can inspect commands all you want before executing them.

If you don't want to require all of Skeptick, you can just require the core, and
and select any specific sugar you want.

```ruby
require 'skeptick/core'
require 'skeptick/sugar/resized_image'
require 'skeptick/sugar/compose'
```

See the `lib/skeptick/sugar` dir for all the goodies.

In Rails Skeptick will automatically use `Rails.logger` and `Rails.root` as
`cd_path`. You can also configure your own.

```ruby
Skeptick.logger  = MyLogger.new
Skeptick.cd_path = '/some/dir'
```

You can enable `debug_mode` to display every executed command in the log.

```ruby
Skeptick.debug_mode = true
```

## Security Note

*Never* insert any user input into any of Skeptick's commands. This should be
obvious. Skeptick executes strings in your shell.

## DSL

![Skeptick Logo](https://raw.github.com/maxim/skeptick/master/logo.png)

Take a look at [logo.rb](logo.rb) to see thow this logo was generated.

A lot is going on in the above script, no worries, it's just a showcase. I bet
the first thing you noticed is a shitstorm of little method names like `canvas`,
`font`, `write`, `draw`, etc. Well, they are all sugar. We will cover sugar
below.

There are actually only 2 useful methods in all of Skeptick: `convert` and
`set`.

### Convert

`convert` can be used both standalone and inside another `convert`. You could
say this.

```ruby
command = convert('image1.png', to: 'image2.png') do
  set :resize, '200x200'
end

# OUTPUT:
# convert image1.png -resize 200x200 image2.png
```

Or you could put it inside, and it will become a parenthesized subcommand.

```ruby
command = convert('image1.png', to: 'image2.png') do
  convert do
    set '+clone'           # pull in image1 into parentheses
    set :resize, '100x100' # resize image1's clone in memory
  end

  set '-compose over'
  set '-composite'
end

# OUTPUT:
# convert image1.png ( +clone -resize 100x100 )
#   -compose over -composite image2.png
```

If you love parentheses a lot, you could nest `convert` infinitely. However,
ImageMagick's `clone`, `delete`, and `swap` are your friends, learn them to
cure parenthethitis.

Oh, speaking of nesting — we can reuse that whole command inside another command
by passing it to `convert` in place of an image filepath.

```ruby
new_command = convert(command, to: 'whatever.png') do
  set '-resize 300x300'
end

# OUTPUT:
# convert
#   ( image1.png ( +clone -resize 100x100 ) -compose over -composite )
#   -resize 300x300 whatever.png
```

See what I did there? The `command` from previous snippet is passed into
`convert`. If you have a `convert` object in a variable, you can use it inside
another `convert` object down the line. Nesting possibilities are endless.

The same snippet could also be written like this.
```ruby
new_command = convert(to: 'whatever.png') do
  image command
  set :resize, '300x300'
end
```

2 differences: 1 - instead of passing in `command` as argument we declare it
inside the block. 2 - resize is a symbol. Any symbol passed into `set`
automatically becomes a string with dash in front of it. Speaking of set.

### Set

`set` adds stuff to your command. You can give it any various arguments, it
doesn't care.

```ruby
# All same thing
set '-resize 100x100'
set '-resize', '100x100'
set :resize, '100x100'
```

In addition to `set` there are also `prepend` and `append` to put stuff at the
beginning or end of a command, but they are rarely useful, and mostly for
implementing your own sugar.

## Sugar

Skeptick comes with a bunch of sugar. When you require Skeptick, you can simply
require everything. This includes all the sugar functionality.

```ruby
require 'skeptick'
```

However, you can require just the core stuff described above, and select any
sugar you want.

```ruby
require 'skeptick/core'
require 'skeptick/sugar/compose'
```

### Compose Sugar

Compose is sugar that adds `compose` shortcut to Skeptick's DSL.

```ruby
command = compose(:multiply, 'a.png', 'b.png', to: 'out.png') do
  set :resize, '200x200'
end

# OUTPUT:
# convert a.png b.png -compose multiply -resize 200x200 -composite out.png
```

It takes the blending type as the first argument, and injects some extra stuff
into the resulting command.

As with `convert`, you don't have to list your images as method arguments.
Instead you could declare them inside the block using the `image` method. The
following command does the same thing.

```ruby
command = compose(:multiply, to: 'out.png') do
  image 'a.png'
  convert 'b.png'
  set :resize, '200x200'
end
```

*Note:* `image` is alias of `convert`.

Since most of Skeptick's power comes from the ability to infinitely nest things,
here's an example involving a nested `compose`.

```ruby
command = convert('image1.png', to: 'result.png') do
  compose(:multiply) do
    image 'image2.png[200x200]'

    convert 'image3.png' do
      set :unsharp, '0x5'
    end
  end
end

# OUTPUT:
# convert
#   image1.png image2.png[200x200] ( image3.png -unsharp 0x5 ) -compose
#   multiply -composite result.png"
```

Notice how we nest `compose` inside of `convert`, and then `convert` inside of
`compose`.

### Compose Operators

This is more of a gimmick than a real feature, but you can use math operators
like `+`, `-`, `*`, `/`, `&`, `|` to compose images. These are all based on
`compose` method. Here's a multiply example.

```ruby
image1 = image('foo.png')
image2 = image('bar.png')
result = convert(image1 * image2, to: 'baz.png')

# OUTPUT:
# convert foo.png bar.png -compose multiply -composite baz.png
```

As you can see, this is equivalent of simply using `compose`.

```ruby
# Same thing
result = compose(:multiply, 'foo.png', 'bar.png', to: 'baz.png')
```

Check out [lib/skeptick/sugar/compose.rb](lib/skeptick/sugar/compose.rb) for
what these operators do.

### clone, delete, swap

Skeptick provides methods `clone`, `delete`, and `swap` to
manipulate declared images in a sequence, just like in ImageMagick CLI.

```ruby
command = compose(:over, 'image1.png', to: 'result.png') do
  # You could think of image sequence as a ruby array. Here's what it would
  # look like right now.
  # [ 'image1.png' ]

  compose(:multiply) do
    image 'mask.png' # loading another image for this operation
    clone(0)         # cloning image1.png from outside "into parentheses"
  end

  # Sequence at this point:
  # [ 'image1.png', 'result of compose(:multiply)' ]

  delete(0) # deleting image1.png from the sequence and from memory

  # Sequence at this point:
  # [ 'result of compose(:multiply)' ]

  # At this point the only image loaded in memory is the one produced by the
  # compose(:multiply) command above. Let's load another one.

  image 'image2.png'

  # Sequence at this point:
  # [ 'result of compose(:multiply)', 'image2.png' ]

  # Now we have two images in the sequence. We can swap them in case we need
  # to change their order.

  swap

  # Sequence at this point:
  # [ 'image2.png', 'result of compose(:multiply)' ]

  # Now image2.png is first in the sequence, and the output of
  # compose(:multiply) is second. Since our outermost command is compose(:over),
  # at this point these 2 images will be composed over each other, and the
  # result written to result.png.
end

# OUTPUT
# convert
#  image1.png ( mask.png -clone 0 -compose multiply -composite )
#  -delete 0 image2.png +swap -compose over -composite result.png
```

You can use `clone` and `delete` to refer to multiple images at once by passing
mutliple indexes as arguments, like `clone(0,1,2)` or `delete(0,1)`. Ranges are
also accepted. Without any arguments `clone` and `delete` are translated to
ImageMagick's `+clone` and `+delete`. They then refer to the last image in the
sequence. Same with `swap` - you can provide two indexes in arguments like
`swap(1,3)` to swap any 2 images in the sequence, or without arguments it'll
act as `+swap` - which swaps last two images.

### Write

Sometimes you might want to take a look at an intermediate image that's being
generated inside parentheses, nested somewhere in your command. You can do so
with the help of `write '/path/to/img.png'`, which is defined in
`skeptick/sugar/write.rb`.

```ruby
command = convert(to: 'result.png') do
  compose(:multiply, 'a.png', 'b.png') do
    write '~/Desktop/debug.png'
  end

  set :resize, '200x200'
end
```

In this case the result of inner `compose` command will be saved to desktop
without affecting anything else. This is a feature that already exists in
ImageMagick, as you can see for yourself from generated command:

    convert
      ( a.png b.png -compose multiply -composite -write ~/Desktop/debug.png )
      -resize 200x200 result.png

Documentation is to be continued...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
