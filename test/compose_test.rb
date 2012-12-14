require_relative 'test_helper'

# DISCLAIMER
# These tests are not examples of proper usage of ImageMagick.
# In fact, most of them are entirely invalid. The point is to
# test the logic of building strings.
class ComposeTest < MiniTest::Unit::TestCase
  include Skeptick

  def test_minimal_compose
    cmd = compose
    assert_equal 'convert -compose -composite miff:-', cmd.to_s
  end

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
    assert_equal 'convert -compose over -foo -composite miff:-', cmd.to_s
  end

  def test_compose_with_concatenated_ops
    cmd = compose(:over) { with '-foo', 'bar' }
    assert_equal 'convert -compose over -foo bar -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_ops
    cmd = compose(:over) { with '-foo'; with '+bar' }
    assert_equal 'convert -compose over -foo +bar -composite miff:-', cmd.to_s
  end

  def test_compose_with_multiple_concatenated_ops
    cmd = compose(:over) { with '-foo', 'bar'; with '+baz', 'qux' }
    assert_equal 'convert -compose over -foo bar +baz qux -composite miff:-',
      cmd.to_s
  end

  def test_compose_with_ops_inputs_and_output
    cmd = compose(:over, 'foo', 'bar', to: 'baz') do
      image 'qux'
      with '+quux'
      with '-corge', 'grault'
    end

    assert_equal 'convert foo bar qux -compose over +quux -corge grault ' +
      '-composite baz', cmd.to_s
  end

  def test_nested_compose
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo') { with 'bar' }
    end

    assert_equal 'convert ( foo -compose multiply bar -composite ) -compose ' +
      'over -composite baz', cmd.to_s
  end

  def test_nested_compose_ignores_output
    cmd = compose(:over, to: 'baz') do
      compose(:multiply, 'foo', to: 'nowhere') { with 'bar' }
    end

    assert_equal 'convert ( foo -compose multiply bar -composite ) -compose ' +
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

    assert_equal 'convert foo ( qux -compose multiply +asdf +fdsa ' +
      '-composite ) bleh -compose over -resize -composite bar', cmd.to_s
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

    assert_equal 'convert foo ( qux -compose over +asdf +fdsa -composite ) ' +
      'bleh -compose multiply -resize -composite bar', cmd.to_s
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

    assert_equal 'convert ( ( ( image1 -compose baz -option qux -composite ' +
      ') image2 -compose bar +option -composite ) -compose foo -composite ) ' +
      'image4 -compose image3 -option quux -composite miff:-', cmd.to_s
  end
end
