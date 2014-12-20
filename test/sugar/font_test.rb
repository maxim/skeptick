require_relative '../test_helper'
require 'skeptick/sugar/font'

class DrawingTest < Skeptick::TestCase
  include Skeptick

  def test_font_in_convert
    cmd = convert { font 'handwriting - dakota Regular' }
    assert_equal 'convert -font Handwriting---Dakota-Regular miff:-', cmd.to_s
  end
end
