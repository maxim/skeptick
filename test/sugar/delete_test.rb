require_relative '../test_helper'
require 'skeptick/sugar/delete'

class DeleteTest < Skeptick::TestCase
  include Skeptick

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
    cmd = convert('foo') { convert('bar') { delete } }
    assert_equal 'convert foo ( bar +delete ) miff:-', cmd.to_s
  end
end
