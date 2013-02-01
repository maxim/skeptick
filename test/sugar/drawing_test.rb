require_relative '../test_helper'
require 'skeptick/sugar/drawing'

class DrawingTest < Skeptick::TestCase
  include Skeptick

  def test_canvas_in_image_with_size
    img = image { canvas :none, size: '100x200' }
    cmd = convert(img)

    assert_equal 'convert -size 100x200 canvas:none miff:-', cmd.to_s
  end

  def test_canvas_in_image_without_size
    img = image { canvas :none }
    cmd = convert(img)
    assert_equal 'convert canvas:none miff:-', cmd.to_s
  end

  def test_canvas_in_convert_with_size
    cmd = convert { canvas :none, size: '100x200' }
    assert_equal 'convert -size 100x200 canvas:none miff:-', cmd.to_s
  end

  def test_canvas_in_convert_without_size
    cmd = convert { canvas :none }
    assert_equal 'convert canvas:none miff:-', cmd.to_s
  end

  def test_draw_in_image
    img = image { draw 'fill none bezier 1,2 3,4' }
    cmd = convert(img)
    assert_equal 'convert -draw fill\ none\ bezier\ 1,2\ 3,4 miff:-', cmd.to_s
  end

  def test_draw_in_convert
    cmd = convert { draw 'fill none bezier 1,2 3,4' }
    assert_equal 'convert -draw fill\ none\ bezier\ 1,2\ 3,4 miff:-', cmd.to_s
  end

  def test_write_in_image_without_left_top
    img = image { write 'Foo bar baz.' }
    cmd = convert(img)
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end

  def test_write_in_image_with_left_top
    img = image { write 'Foo bar baz.', left: 7, top: 9 }
    cmd = convert(img)
    assert_equal 'convert -draw text\ 7,9\ \\\'Foo\ bar\ baz.\\\' miff:-',
      cmd.to_s
  end

  def test_write_in_image_with_left_only
    img = image { write 'Foo bar baz.', left: 7 }
    cmd = convert(img)
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end

  def test_write_in_convert_without_left_top
    cmd = convert { write 'Foo bar baz.' }
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end

  def test_write_in_convert_with_left_top
    cmd = convert { write 'Foo bar baz.', left: 7, top: 9 }
    assert_equal 'convert -draw text\ 7,9\ \\\'Foo\ bar\ baz.\\\' miff:-',
      cmd.to_s
  end

  def test_write_in_convert_with_top_only
    cmd = convert { write 'Foo bar baz.', top: 9 }
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end

  def test_font_in_image
    img = image { font 'handwriting - dakota Regular' }
    cmd = convert(img)
    assert_equal 'convert -font Handwriting---Dakota-Regular miff:-', cmd.to_s
  end

  def test_font_in_convert
    cmd = convert { font 'handwriting - dakota Regular' }
    assert_equal 'convert -font Handwriting---Dakota-Regular miff:-', cmd.to_s
  end
end
