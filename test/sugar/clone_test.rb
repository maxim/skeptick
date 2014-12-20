require_relative '../test_helper'
require 'skeptick/sugar/clone'

class CloneTest < Skeptick::TestCase
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
    cmd = convert('foo') { convert { clone; set :bar } }
    assert_equal 'convert foo ( +clone -bar ) miff:-', cmd.to_s
  end
end
