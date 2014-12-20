require_relative '../test_helper'
require 'skeptick/sugar/canvas'

class DrawingTest < Skeptick::TestCase
  include Skeptick

  def test_canvas_in_convert_with_size
    cmd = convert { canvas :none, size: '100x200' }
    assert_equal 'convert -size 100x200 canvas:none miff:-', cmd.to_s
  end

  def test_canvas_in_convert_without_size
    cmd = convert { canvas :none }
    assert_equal 'convert canvas:none miff:-', cmd.to_s
  end
end
