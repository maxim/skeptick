require_relative '../test_helper'
require 'skeptick/sugar/draw'

class DrawTest < Skeptick::TestCase
  include Skeptick

  def test_draw_in_convert
    cmd = convert { draw 'fill none bezier 1,2 3,4' }
    assert_equal 'convert -draw fill\ none\ bezier\ 1,2\ 3,4 miff:-', cmd.to_s
  end
end
