require_relative '../test_helper'
require 'skeptick/sugar/composition'

# DISCLAIMER
# These tests are not examples of proper usage of ImageMagick.
# In fact, most of them are entirely invalid. The point is to
# test the logic of building strings.
class CompositionTest < Skeptick::TestCase
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
    cmd = compose(:over) { with '-foo' }
    assert_equal 'convert -foo -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_concatenated_ops
    cmd = compose(:over) { with '-foo', 'bar' }
    assert_equal 'convert -foo bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_ops
    cmd = compose(:over) { with '-foo'; with '+bar' }
    assert_equal 'convert -foo +bar -compose over -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_concatenated_ops
    cmd = compose(:over) { with '-foo', 'bar'; with '+baz', 'qux' }
    assert_equal 'convert -foo bar +baz qux -compose over -composite miff:-',
      cmd.to_s
  end

  def test_compose_with_ops_inputs_and_output
    cmd = compose(:over, 'foo', 'bar', to: 'baz') do
      image 'qux'
      with '+quux'
      with '-corge', 'grault'
    end

    assert_equal 'convert foo bar qux +quux -corge grault -compose over ' +
      '-composite baz', cmd.to_s
  end

  def test_nested_compose
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo') { with 'bar' }
    end

    assert_equal 'convert ( foo bar -compose multiply -composite ) -compose ' +
      'over -composite baz', cmd.to_s
  end

  def test_nested_compose_ignores_output
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo', to: 'nowhere') { with 'bar' }
    end

    assert_equal 'convert ( foo bar -compose multiply -composite ) -compose ' +
      'over -composite baz', cmd.to_s
  end

  def test_multi_image_nested_compose
    cmd = compose(:over, 'foo', to: 'bar') do
      compose(:multiply, 'qux') do
        with '+asdf'
        with '+fdsa'
      end

      image 'bleh'
      with '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa -compose multiply ' +
      '-composite ) bleh -resize -compose over -composite bar', cmd.to_s
  end

  def test_compose_composition
    complex_image = compose(:over, 'qux') do
      with '+asdf'
      with '+fdsa'
    end

    cmd = compose(:multiply, 'foo', to: 'bar') do
      image complex_image
      image 'bleh'
      with '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa -compose over -composite ) ' +
      'bleh -resize -compose multiply -composite bar', cmd.to_s
  end

  def test_compose_double_nesting_with_composition
    complex_image = compose('foo', to: 'nowhere') do
      compose('bar', to: 'nowhere') do
        compose('baz') do
          image 'image1'
          with '-option', 'qux'
        end

        image 'image2'
        with '+option'
      end
    end

    cmd = compose('image3') do
      image complex_image
      image 'image4'
      with '-option', 'quux'
    end

    assert_equal 'convert ( ( ( image1 -option qux -compose baz -composite ' +
      ') image2 +option -compose bar -composite ) -compose foo -composite ) ' +
      'image4 -option quux -compose image3 -composite miff:-', cmd.to_s
  end

  def test_plus_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs + rhs)

    assert_equal 'convert ( foo bar -compose over -composite ) miff:-',
      result.to_s
  end

  def test_minus_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs - rhs)

    assert_equal 'convert ( foo bar -compose dstout -composite ) miff:-',
      result.to_s
  end

  def test_multiply_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs * rhs)

    assert_equal 'convert ( foo bar -compose multiply -composite ) miff:-',
      result.to_s
  end

  def test_divide_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs / rhs)

    assert_equal 'convert ( foo bar -compose divide -composite ) miff:-',
      result.to_s
  end

  def test_and_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs & rhs)

    assert_equal 'convert ( foo bar -alpha Set -compose dstin -composite ) ' +
      'miff:-', result.to_s
  end

  def test_or_operator_on_image
    lhs = image('foo')
    rhs = image('bar')
    result = convert(lhs | rhs)

    assert_equal 'convert ( foo bar -compose dstover -composite ) miff:-',
      result.to_s
  end

  def test_plus_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs + rhs

    assert_equal 'convert ( foo ) ( bar ) -compose over -composite miff:-',
      result.to_s
  end

  def test_minus_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs - rhs

    assert_equal 'convert ( foo ) ( bar ) -compose dstout -composite miff:-',
      result.to_s
  end

  def test_multiply_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs * rhs

    assert_equal 'convert ( foo ) ( bar ) -compose multiply -composite miff:-',
      result.to_s
  end

  def test_divide_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs / rhs

    assert_equal 'convert ( foo ) ( bar ) -compose divide -composite miff:-',
      result.to_s
  end

  def test_and_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs & rhs

    assert_equal 'convert ( foo ) ( bar ) -alpha Set -compose dstin ' +
      '-composite miff:-', result.to_s
  end

  def test_or_operator_on_convert
    lhs = convert('foo')
    rhs = convert('bar')
    result = lhs | rhs

    assert_equal 'convert ( foo ) ( bar ) -compose dstover -composite miff:-',
      result.to_s
  end
end
