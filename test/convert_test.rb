require_relative 'test_helper'

# DISCLAIMER
# These tests are not examples of proper usage of ImageMagick.
# In fact, most of them are entirely invalid. The point is to
# test the logic of building strings.
class ConvertTest < MiniTest::Unit::TestCase
  include Skeptick

  def test_dsl_methods_available
    assert_respond_to self, :convert
    assert_respond_to self, :image
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

  def test_nested_convert_ignores_output
    cmd = convert(to: 'baz') do
      convert('foo', to: 'nowhere') { with 'bar' }
    end

    assert_equal 'convert ( foo bar ) baz', cmd.to_s
  end

  def test_multi_image_nested_convert
    cmd = convert('foo', to: 'bar') do
      convert('qux') do
        with '+asdf'
        with '+fdsa'
      end

      image 'bleh'
      with '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa ) bleh -resize bar', cmd.to_s
  end

  def test_convert_composition
    complex_image = convert('qux') do
      with '+asdf'
      with '+fdsa'
    end

    cmd = convert('foo', to: 'bar') do
      image complex_image
      image 'bleh'
      with '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa ) bleh -resize bar', cmd.to_s
  end

  def test_convert_double_nesting_with_composition
    complex_image = convert('foo', to: 'nowhere') do
      convert('bar', to: 'nowhere') do
        convert('baz') do
          image 'image1'
          with '-option', 'qux'
        end

        image 'image2'
        with '+option'
      end
    end

    cmd = convert('image3') do
      image complex_image
      image 'image4'
      with '-option', 'quux'
    end

    assert_equal 'convert image3 ( foo ( bar ( baz image1 -option qux ) ' +
      'image2 +option ) ) image4 -option quux miff:-', cmd.to_s
  end
end
