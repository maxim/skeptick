require_relative '../test_helper'
require 'skeptick/sugar/swap'

class SwapTest < Skeptick::TestCase
  include Skeptick

  def test_swap_without_args
    cmd = convert { swap }
    assert_equal 'convert +swap miff:-', cmd.to_s
  end

  def test_swap_with_one_arg_raises_error
    assert_raises(ArgumentError) do
      convert{ swap(1) }.to_s
    end
  end

  def test_swap_with_two_args
    cmd = convert('foo', 'bar') { swap(1,2) }
    assert_equal 'convert foo bar -swap 1,2 miff:-', cmd.to_s
  end

  def test_swap_with_three_args_raises_error
    assert_raises(ArgumentError) do
      convert{ swap(1,2,3) }.to_s
    end
  end
end
