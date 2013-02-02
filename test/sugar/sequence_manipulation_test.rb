require_relative '../test_helper'
require 'skeptick/sugar/sequence_manipulation'

class SequenceManipulationTest < Skeptick::TestCase
  include Skeptick

  def test_clone_without_args
    cmd = convert { clone }
    assert_equal 'convert +clone miff:-', cmd.to_s
  end

  def test_clone_with_one_arg
    cmd = convert { clone(1) }
    assert_equal 'convert -clone 1 miff:-', cmd.to_s
  end

  def test_clone_with_two_args
    cmd = convert { clone(1,3) }
    assert_equal 'convert -clone 1,3 miff:-', cmd.to_s
  end

  def test_clone_with_array
    cmd = convert { clone([1,3]) }
    assert_equal 'convert -clone 1,3 miff:-', cmd.to_s
  end

  def test_clone_with_inclusive_range
    cmd = convert { clone(1..3) }
    assert_equal 'convert -clone 1-3 miff:-', cmd.to_s
  end

  def test_clone_with_exclusive_range
    cmd = convert { clone(1...3) }
    assert_equal 'convert -clone 1-2 miff:-', cmd.to_s
  end

  def test_clone_in_nested_convert
    cmd = convert { convert { clone } }
    assert_equal 'convert ( +clone ) miff:-', cmd.to_s
  end

  def test_delete_without_args
    cmd = convert { delete }
    assert_equal 'convert +delete miff:-', cmd.to_s
  end

  def test_delete_with_one_arg
    cmd = convert { delete(1) }
    assert_equal 'convert -delete 1 miff:-', cmd.to_s
  end

  def test_delete_with_two_args
    cmd = convert { delete(1,3) }
    assert_equal 'convert -delete 1,3 miff:-', cmd.to_s
  end

  def test_delete_with_array
    cmd = convert { delete([1,3]) }
    assert_equal 'convert -delete 1,3 miff:-', cmd.to_s
  end

  def test_delete_with_inclusive_range
    cmd = convert { delete(1..3) }
    assert_equal 'convert -delete 1-3 miff:-', cmd.to_s
  end

  def test_delete_with_exclusive_range
    cmd = convert { delete(1...3) }
    assert_equal 'convert -delete 1-2 miff:-', cmd.to_s
  end

  def test_delete_in_nested_convert
    cmd = convert { convert { delete } }
    assert_equal 'convert ( +delete ) miff:-', cmd.to_s
  end

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
    cmd = convert { swap(1,2) }
    assert_equal 'convert -swap 1,2 miff:-', cmd.to_s
  end

  def test_swap_with_three_args_raises_error
    assert_raises(ArgumentError) do
      convert{ swap(1,2,3) }.to_s
    end
  end
end
