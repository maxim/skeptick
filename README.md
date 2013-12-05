### A note on project status

If looking at commits makes you think that this project is abandoned, it's not. Skeptick is being used in our production ever since its inception, and it's working great. The reason there is no new activity is as follows.

* It's really working great for us
* Nobody is submitting issues

So don't let the lack of git activity fool you. I have plans to blog about some interesting use cases for Skeptick and link to them from this README, stay tuned.

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

    cmd.build
  end
end
```

The `cmd` object seen in above example can be inspected to see the exact command
that Skeptick will run. Simply use `cmd.inspect` or `cmd.to_s`. Skeptick never
runs anything until you call `build` (except for one very special case), so you
can inspect commands all you want before executing them.

If you don't want to require all of Skeptick, you can just require the core, and
and select any specific sugar you want.

```ruby
require 'skeptick/core'
require 'skeptick/sugar/resizing'
require 'skeptick/sugar/composition'
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

This picture is produced with the following script

```ruby
include Skeptick

image_size = '400x120'
left, top  = 8, 80

# Build a picture with built-in tile:granite: texture and using the
# skeptick-provided sugar method `rounded_corners_image`
paper = rounded_corners_image(size: image_size, radius: 25) do
  set   :size, image_size
  image 'tile:granite:'
  apply '-brightness-contrast', '38x-33'
  apply :blur, '0x0.5'
end

# Build a text image that says "Skeptick" using specified font, add gradient
text = image do
  canvas :none, size: '395x110'
  font   'Handwriting - Dakota Regular'
  set    :pointsize, 90
  set    :fill, 'gradient:#37e-#007'
  write  'Skeptick', left: left, top: top
  apply  :blur, '0x0.7'
end

bezier = \
  "#{left + 17 }, #{top + 17}   #{left + 457}, #{top - 13} " +
  "#{left + 377}, #{top + 27}   #{left + 267}, #{top + 27}"

# Draw a curve that will appear underneath the text using bezier coordinates
curve = image do
  canvas :none, size: '395x110'
  set    :strokewidth, 2
  set    :stroke, 'gradient:#37e-#007'
  draw   "fill none bezier #{bezier}"
end

# Combine text and curve using `:over` blending, multiply it with paper using
# `:multiply` blending, and add a torn effect using Skeptick-provided sugar
# method `torn_paper_image`
torn = torn_paper_image(
  paper * (text + curve),
  spread: 50,
  blur:   '3x10'
)

# Create a convert command with all of the above and run it
logo = convert(torn, to: "#{File.dirname(__FILE__)}/logo.png")
logo.build

# This is what the resulting command looks like
# You can see it by running `logo.to_s`
#
# convert (
#   (
#     (
#       -size 400x120 tile:granite:
#       -brightness-contrast 38x-33 -blur 0x0.5
#       (
#         +clone -alpha transparent -background none
#         -draw roundrectangle 1,1 400,120 25,25
#       )
#       -alpha set -compose dstin -composite
#     )
#
#     (
#       -size 395x110 canvas:none
#       -font Handwriting---Dakota-Regular -pointsize 90
#       -fill gradient:#37e-#007 -draw text 8,80 'Skeptick'
#       -blur 0x0.7 -size 395x110 canvas:none -strokewidth 2
#       -stroke gradient:#37e-#007
#       -draw fill none
#         bezier 25, 97   465, 67 385, 107   275, 107
#       -compose over -composite
#     )
#
#     -compose multiply -composite
#   )
#
#   (
#     +clone -alpha extract -virtual-pixel black -spread 50
#     -blur 0x3 -threshold 50% -spread 1 -blur 0x.7
#   )
#
#   -alpha off -compose copy_opacity -composite
# ) logo.png

```

## All those little commands

A lot of things happened in the above script, no worries, it's just a showcase.
I bet the first thing you noticed is a shitstorm of little method names like
`apply`, `canvas`, `font`, `write`, `draw`, etc. Well, they are all sugar. We
will cover sugar later in teh given parchment.

There are actually only three real commands in all of Skeptick: `convert`,
`set`, and `image`.

### Convert

`convert` can be used both outside and inside a transformation block. You could
say for example this.

```ruby
command = convert('image1.png', to: 'image2.png') do
  set '-resize', '200x200'
end

# OUTPUT:
# convert image1.png -resize 200x200 image2.png
```

Or you could put it inside, and it will become a parenthesized subcommand.

```ruby
command = convert('image1.png', to: 'image2.png') do
  convert do
    set '+clone'          # pull in image1 into parentheses
    set '-resize 100x100' # resize image1's clone in memory
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

See what I did there? It's composability. If you have a `convert` object in a
variable, you can use it inside another `convert` object down the line.

### Set

`set` appends a string to your command. You can give it any arguments, it
doesn't care, it will just `to_s` and concatenate them.

```ruby
# All same thing
set '-resize 100x100'
set '-resize', '100x100'
set :resize, '100x100'
```

Yeah that last one is special convenience. If an argument to `set` is a symbol,
it will convert it to `"-#{symbol}"`. If you need `+resize` type of thing you'd
just have to use a string, or sugar, but later on that.

### Image

`image` is very similar to `convert`. However, `convert` is a command object
that may contain many images, settings, operators, nested converts, etc. Image
is also a command object that can contain many settings and operators, but it
can only contain one image reference inside of it. The reference can be a path,
a nested convert, or a special string representing a built-in imagemagick image,
but it can be only one.

```ruby
command = convert(to: '/path/to/result.png') do
  image '/path/to/image.png'
  set :resize, '200x200'
end

# OUTPUT:
# convert /path/to/image.png -resize 200x200 /path/to/result.png
```

In this case we declared an image inside a `convert` which references a path.
Instead we could create an image that references a built-in image.

```ruby
command = convert(to: '/path/to/result.png') do
  image 'rose:'
end

# OUTPUT:
# convert rose: /path/to/result.png
```

You can save image objects in variables, and pass them around, but unlike
`convert`, you cannot run them standalone.

```ruby
rose_image = image('rose:')
command = convert(rose_image, to: '/path/to/result.png')

# OUTPUT:
# convert rose: /path/to/result.png
```
See, we had to wrap it in a `convert` in order to use it. You could also append
this image at any point inside the convert block.

```ruby
rose_image = image('rose:')
command = convert(to: '/path/to/result.png') do
  image rose_image
end

# OUTPUT:
# convert rose: /path/to/result.png
```

As mentioned above, an image can come with its own settings and operators.

```ruby
rose_image = image do
  set :background, 'transparent'
  image 'rose:'
  apply :resize, '200x200'
end

command = convert(to: '/path/to/result.png') do
  image rose_image
end
```

You could do all of this inline, the output will be the same.

```ruby
command = convert(to: '/path/to/result.png') do
  image do
    set :background, 'transparent'
    image 'rose:'
    apply :resize, '200x200'
  end
end

# OUTPUT:
# convert -background transparent rose: -resize 200x200 /path/to/result.png
```

If you have a `convert` object you can pass it as an image too.

```ruby
saved_convert = convert(to: 'foo.png') do
  image 'rose:'
  set :resize, '200x200'
end

another_convert = convert(to: 'bar.png') do
  image saved_convert
  apply :blur, '0x0.5'
end

# OUTPUT
# convert ( rose: -resize 200x200 ) -blur 0x0.5 bar.png
```

Nesting possibilities are endless.

## Sugar

Skeptick comes with a bunch of sugar. When you require Skeptick, you can simply
require everything. This includes all the sugar.

```ruby
require 'skeptick'
```

However, you can require just the core stuff described above, and select any
sugar you want.

```ruby
require 'skeptick/core'
require 'skeptick/sugar/composition'
```

### Composition Sugar

Composition is sugar that adds `compose` shortcut to Skeptick's DSL.

```ruby
command = compose(:multiply, 'a.png', 'b.png', to: 'out.png') do
  set :resize, '200x200'
end

# OUTPUT:
# convert a.png b.png -compose multiply -resize 200x200 -composite out.png
```

It takes the blending type as the first argument, and injects some extra stuff
into the resulting command, but really it's just a wrapper around `convert` as
you could easily see in its implementation.

```ruby
def compose(blending, *args, &blk)
  convert(*args, &blk).tap do |c|
    c.append :compose, blending.to_s
    c.append :composite
  end
end
```

As usual, you don't have to list your images as method arguments like that.
Instead you could declare them inside the block using the `image` method. The
following command does the same thing.

```ruby
command = compose(:multiply, to: 'out.png') do
  image 'a.png'
  image 'b.png'
  set :resize, '200x200'
end
```

Since most of Skeptick's power comes from the ability to infinitely nest things,
here's a an example involving a nested `compose`.

```ruby
command = convert('image1.png', to: 'result.png') do
  compose(:multiply) do
    image 'image3.png[200x200]'

    convert 'image4.png' do
      set :unsharp, '0x5'
    end

  end
end

# OUTPUT:
# convert
#   image1.png ( image3.png[200x200] ( image4.png -unsharp 0x5 ) -compose
#   multiply -composite ) result.png"
```

Notice how we nest `compose` inside of `convert`, and then `convert` inside of
`compose`. The output of each acts like any declared image. In other words,
wherever you would write `image "foo.png"` you could also write a nested
command.

### Composition Operators

This is more of a gimmick than a real feature, but you can use math operators
like `+`, `-`, `*`, `/`, `&`, `|` to compose images. These are all based on
`compose` method. Here's a multiply example.

```ruby
image1 = image('foo.png')
image2 = image('bar.png')
result = convert(image1 * image2, to: 'baz.png')

# OUTPUT:
# convert ( foo.png bar.png -compose multiply -composite ) baz.png
```

As you can see, this is equivalent of simply using `compose`.

```ruby
# Same thing
result = compose(:multiply, 'foo.png', 'bar.png', to: 'baz.png')
```

Check out `lib/skeptick/sugar/composition.rb` for what these operators do.

### Sequence Manipulation Sugar

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

### Debugging Sugar

Sometimes you might want to take a look at an intermediate image that's being
generated inside parentheses, nested somewhere in your command. You can do so
with the help of `save('/path/to/img.png')`, which is defined in
`skeptick/sugar/debugging.rb`.

```ruby
command = convert(to: 'result.png') do
  compose(:multiply, 'a.png', 'b.png') do
    save('~/Desktop/debug.png')
  end

  set '-resize', '200x200'
end
```

In this case the result of inner `compose` command will be saved to desktop
without affecting anything else. Again, this is a feature that already exists
in ImageMagick, as becomes apparent from the resulting command.

    convert
      ( a.png b.png -compose multiply -composite -write ~/Desktop/debug.png )
      -resize 200x200 result.png

## Chain

This is rarely (if ever) needed, but with Skeptick you could easily create
piped commands.

```ruby
command = chain(to: 'result.png') do
  compose(:hardlight, 'a.png', 'b.png') do
    set '-brightness-contrast', '2x4'
  end

  compose(:atop, 'c.png', :pipe)
end

# OUTPUT:
# convert
#   a.png b.png -compose hardlight -brightness-contrast 2x4 -composite miff:- |
# convert
#   c.png miff:- -compose atop -composite result.png
```

Two things to note here. First of all, commands that are declared in the `chain`
block will become piped together. Second, we use a special `:pipe` symbol in
the last `compose` command. This symbol indicates where the piped-in image
should appear in the image sequence. You can see this in the output string. The
`miff:-` appears after c.png, as expected.

Documentation is to be continued...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
