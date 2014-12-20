require_relative '../test_helper'
require 'skeptick/sugar/compose'

# DISCLAIMER
# These tests are not examples of proper usage of ImageMagick.
# In fact, most of them are entirely invalid. The point is to
# test the logic of building strings.
class ComposeTest < Skeptick::TestCase
  include Skeptick

  def test_compose_with_blending
    cmd = compose(:over)
    assert_equal 'convert -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_input
    cmd = compose(:over, 'foo')
    assert_equal 'convert foo -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_2_inputs
    cmd = compose(:over, 'foo', 'bar')
    assert_equal 'convert foo bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_output
    cmd = compose(:over, to: 'foo')
    assert_equal 'convert -compose over -composite foo', cmd.to_s
  end

  def test_compose_with_input_and_output
    cmd = compose(:over, 'foo', to: 'bar')
    assert_equal 'convert foo -compose over -composite bar', cmd.to_s
  end

  def test_compose_with_2_inputs_and_output
    cmd = compose(:over, 'foo', 'bar', to: 'baz')
    assert_equal 'convert foo bar -compose over -composite baz', cmd.to_s
  end

  def test_compose_with_input_in_block
    cmd = compose(:over) { image 'foo' }
    assert_equal 'convert foo -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_input_in_block_and_output
    cmd = compose(:over, to: 'bar') { image 'foo' }
    assert_equal 'convert foo -compose over -composite bar', cmd.to_s
  end

  def test_compose_with_2_input_styles
    cmd = compose(:over, 'foo') { image 'bar' }
    assert_equal 'convert foo bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_2_input_styles_and_output
    cmd = compose(:over, 'foo', to: 'baz') { image 'bar' }
    assert_equal 'convert foo bar -compose over -composite baz', cmd.to_s
  end

  def test_compose_with_ops
    cmd = compose(:over) { set '-foo' }
    assert_equal 'convert -foo -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_concatenated_ops
    cmd = compose(:over) { set '-foo', 'bar' }
    assert_equal 'convert -foo bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_ops
    cmd = compose(:over) { set '-foo'; set '+bar' }
    assert_equal 'convert -foo +bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_concatenated_ops
    cmd = compose(:over) { set '-foo', 'bar'; set '+baz', 'qux' }
    assert_equal 'convert -foo bar +baz qux -compose over -composite miff:-',
      cmd.to_s
  end

  def test_compose_with_ops_inputs_and_output
    cmd = compose(:over, 'foo', 'bar', to: 'baz') do
      image 'qux'
      set '+quux'
      set :corge, 'grault'
    end

    assert_equal 'convert foo bar qux +quux -corge grault -compose over ' +
      '-composite baz', cmd.to_s
  end

  def test_nested_compose
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo') { set 'bar' }
    end

    assert_equal 'convert ( foo bar -compose multiply -composite ) -compose ' +
      'over -composite baz', cmd.to_s
  end

  def test_nested_compose_ignores_output
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo', to: 'nowhere') { set 'bar' }
    end

    assert_equal 'convert ( foo bar -compose multiply -composite ) -compose ' +
      'over -composite baz', cmd.to_s
  end

  def test_multi_image_nested_compose
    cmd = compose(:over, 'foo', to: 'bar') do
      compose(:multiply, 'qux') do
        set '+asdf'
        set '+fdsa'
      end

      image 'bleh'
      set '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa -compose multiply ' +
      '-composite ) bleh -resize -compose over -composite bar', cmd.to_s
  end

  def test_compose_composition
    complex_image = compose(:over, 'qux') do
      set '+asdf'
      set '+fdsa'
    end

    cmd = compose(:multiply, 'foo', to: 'bar') do
      image complex_image
      image 'bleh'
      set '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa -compose over -composite ) ' +
      'bleh -resize -compose multiply -composite bar', cmd.to_s
  end

  def test_compose_double_nesting_with_composition
    complex_image = compose(:multiply, to: 'nowhere') do
      compose(:over, to: 'nowhere') do
        compose(:hardlight) do
          image 'image1'
          set :option, 'qux'
        end

        image 'image2'
        set '+option'
      end
    end

    cmd = compose(:screen) do
      image complex_image
      image 'image3'
      set :option, 'quux'
    end

    assert_equal 'convert ( '\
      '( ( image1 -option qux -compose hardlight -composite ) '\
      'image2 +option -compose over -composite '\
    ') -compose multiply -composite ) '\
    'image3 -option quux -compose screen -composite miff:-', cmd.to_s
  end

  def test_plus_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs + rhs

    assert_equal 'convert foo bar -compose over -composite miff:-',
      result.to_s
  end

  def test_minus_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs - rhs

    assert_equal 'convert foo bar -compose dstout -composite miff:-',
      result.to_s
  end

  def test_multiply_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs * rhs

    assert_equal 'convert foo bar -compose multiply -composite miff:-',
      result.to_s
  end

  def test_divide_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs / rhs

    assert_equal 'convert foo bar -compose divide -composite miff:-',
      result.to_s
  end

  def test_and_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs & rhs

    assert_equal 'convert foo bar -alpha Set -compose dstin ' +
      '-composite miff:-', result.to_s
  end

  def test_or_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs | rhs

    assert_equal 'convert foo bar -compose dstover -composite miff:-',
      result.to_s
  end
end
