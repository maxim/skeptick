require_relative '../test_helper'
require 'skeptick/sugar/text'

class TextTest < Skeptick::TestCase
  include Skeptick

  def test_text_in_convert_without_left_top
    cmd = convert { text 'Foo bar baz.' }
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end

  def test_text_in_convert_with_left_top
    cmd = convert { text 'Foo bar baz.', left: 7, top: 9 }
    assert_equal 'convert -draw text\ 7,9\ \\\'Foo\ bar\ baz.\\\' miff:-',
      cmd.to_s
  end

  def test_text_in_convert_with_top_only
    cmd = convert { text 'Foo bar baz.', top: 9 }
    assert_equal 'convert -draw text\ \\\'Foo\ bar\ baz.\\\' miff:-', cmd.to_s
  end
end
