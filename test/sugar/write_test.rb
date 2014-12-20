require_relative '../test_helper'
require 'skeptick/sugar/write'

class WriteTest < Skeptick::TestCase
  include Skeptick

  def test_write_in_convert
    cmd = convert('foo') do
      write 'path'
    end

    assert_equal 'convert foo -write path miff:-', cmd.to_s
  end
end
