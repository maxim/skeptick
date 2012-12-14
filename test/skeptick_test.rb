require 'bundler/setup'
require 'skeptick'
require 'minitest/autorun'

class SkeptickTest < MiniTest::Unit::TestCase
  include Skeptick

  def test_dsl_methods_available
    assert_respond_to self, :convert
    assert_respond_to self, :compose
    assert_respond_to self, :pipe
  end

  def test_minimal_convert
    cmd = convert
    assert_equal 'convert miff:-', cmd.to_s
  end

  def test_convert_with_input
    cmd = convert('foo')
    assert_equal 'convert foo miff:-', cmd.to_s
  end

  def test_convert_with_2_inputs
    cmd = convert('foo', 'bar')
    assert_equal 'convert foo bar miff:-', cmd.to_s
  end

  def test_convert_with_output
    cmd = convert(to: 'foo')
    assert_equal 'convert foo', cmd.to_s
  end

  def test_convert_with_input_and_output
    cmd =  convert('foo', to: 'bar')
    assert_equal 'convert foo bar', cmd.to_s
  end

  def test_convert_with_2_inputs_and_output
    cmd = convert('foo', 'bar', to: 'baz')
    assert_equal 'convert foo bar baz', cmd.to_s
  end

  def test_convert_with_input_in_block
    cmd = convert { image 'foo' }
    assert_equal 'convert foo miff:-', cmd.to_s
  end

  def test_convert_with_input_in_block_and_output
    cmd = convert(to: 'bar') { image 'foo' }
    assert_equal 'convert foo bar', cmd.to_s
  end

  def test_convert_with_2_input_styles
    cmd = convert('foo') { image 'bar' }
    assert_equal 'convert foo bar miff:-', cmd.to_s
  end

  def test_convert_with_2_input_styles_and_output
    cmd = convert('foo', to: 'baz') { image 'bar' }
    assert_equal 'convert foo bar baz', cmd.to_s
  end

  def test_convert_with_ops
    cmd = convert { with '-foo' }
    assert_equal 'convert -foo miff:-', cmd.to_s
  end

  def test_convert_with_concatenated_ops
    cmd = convert { with '-foo', 'bar' }
    assert_equal 'convert -foo bar miff:-', cmd.to_s
  end

  def test_convert_with_multiple_ops
    cmd = convert { with '-foo'; with '+bar' }
    assert_equal 'convert -foo +bar miff:-', cmd.to_s
  end

  def test_convert_with_multiple_concatenated_ops
    cmd = convert { with '-foo', 'bar'; with '+baz', 'qux' }
    assert_equal 'convert -foo bar +baz qux miff:-', cmd.to_s
  end

  def test_convert_with_multiple_ops
    cmd = convert { with '-foo'; with '+bar' }
    assert_equal 'convert -foo +bar miff:-', cmd.to_s
  end

  def test_convert_with_ops_inputs_and_output
    cmd = convert('foo', 'bar', to: 'baz') do
      image 'qux'
      with '+quux'
      with '-corge', 'grault'
    end

    assert_equal 'convert foo bar qux +quux -corge grault baz', cmd.to_s
  end

  def test_nested_convert
    cmd = convert(to: 'baz') do
      convert('foo') { with 'bar' }
    end

    assert_equal 'convert ( foo bar ) baz', cmd.to_s
  end
end
