require_relative '../test_helper'
require 'skeptick/sugar/formatting'

class FormattingTest < Skeptick::TestCase
  include Skeptick

  def test_format_in_image
    img = image { format "roundrectangle 1,1 %[fx:w], %[fx:h] 5,5" }
    cmd = convert(img)
    assert_equal 'convert -format roundrectangle\ 1,1\ \%\[fx:w\],\ ' +
      '\%\[fx:h\]\ 5,5 miff:-', cmd.to_s
  end

  def test_format_in_convert
    cmd = convert { format "roundrectangle 1,1 %[fx:w], %[fx:h] 5,5" }
    assert_equal 'convert -format roundrectangle\ 1,1\ \%\[fx:w\],\ ' +
      '\%\[fx:h\]\ 5,5 miff:-', cmd.to_s
  end
end
