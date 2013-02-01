require_relative '../test_helper'
require 'skeptick/sugar/debugging'

class DebuggingTest < Skeptick::TestCase
  include Skeptick

  def test_save_in_image
    img = image do
      image 'foo'
      save  'path'
    end

    cmd = convert(img)
    assert_equal 'convert foo -write path miff:-', cmd.to_s
  end

  def test_save_in_convert
    cmd = convert('foo') do
      save 'path'
    end

    assert_equal 'convert foo -write path miff:-', cmd.to_s
  end
end
