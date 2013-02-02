require_relative '../test_helper'
require 'skeptick/sugar/resizing'

class ResizingTest < Skeptick::TestCase
  include Skeptick

  def test_resize_image_with_geometry_options
    img = resized_image('foo', width: 200, shrink_only: true)
    cmd = convert(img)
    assert_equal 'convert foo[200x>] miff:-', cmd.to_s
  end

  def test_resize_image_nested_via_lvar
    img = resized_image('foo', width: 200, shrink_only: true)
    cmd = convert { image(img) }
    assert_equal 'convert foo[200x>] miff:-', cmd.to_s
  end

  def test_resize_image_nested_via_block
    cmd = convert do
      resized_image('foo', height: 100, shrink_only: true)
    end
    assert_equal 'convert foo[x100>] miff:-', cmd.to_s
  end
end
