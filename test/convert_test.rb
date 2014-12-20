require_relative 'test_helper'

# DISCLAIMER
# These tests are not examples of proper usage of ImageMagick.
# In fact, most of them are entirely invalid. The point is to
# test the logic of building strings.
class ConvertTest < Skeptick::TestCase
  include Skeptick

  def test_dsl_method_convert_available
    assert_respond_to self, :convert
  end

  def test_dsl_method_image_available
    assert_respond_to self, :image
  end

  def test_set_adds_setting_to_convert_segment
    cmd = convert do
      image 'bar'
      set '-foo'
    end

    assert_equal 'convert bar -foo miff:-', cmd.to_s
  end

  def test_append_appends_to_convert_segment
    cmd = convert do
      image do
        append '-foo'
        image 'bar'
      end
    end

    assert_equal 'convert bar -foo miff:-', cmd.to_s
  end

  def test_lvars_from_external_context_are_accessible
    foo = '-test'
    cmd = convert { set foo }
    assert_equal 'convert -test miff:-', cmd.to_s
  end

  def test_methods_from_external_context_are_accessible
    context = Class.new do
      include Skeptick
      def foo; :foo end
      def cmd; convert { set foo } end
    end

    assert_equal 'convert -foo miff:-', context.new.cmd.to_s
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
    cmd = convert { set :foo }
    assert_equal 'convert -foo miff:-', cmd.to_s
  end

  def test_convert_with_concatenated_ops
    cmd = convert { set '-foo', 'bar' }
    assert_equal 'convert -foo bar miff:-', cmd.to_s
  end

  def test_convert_with_multiple_ops
    cmd = convert { set '-foo'; set '+bar' }
    assert_equal 'convert -foo +bar miff:-', cmd.to_s
  end

  def test_convert_with_multiple_concatenated_ops
    cmd = convert { set '-foo', 'bar'; set '+baz', 'qux' }
    assert_equal 'convert -foo bar +baz qux miff:-', cmd.to_s
  end

  def test_convert_with_ops_inputs_and_output
    cmd = convert('foo', 'bar', to: 'baz') do
      image 'qux'
      set '+quux'
      set :corge, 'grault'
    end

    assert_equal 'convert foo bar qux +quux -corge grault baz', cmd.to_s
  end

  def test_nested_convert
    cmd = convert(to: 'baz') do
      convert('foo') { set '-bar' }
    end

    assert_equal 'convert foo -bar baz', cmd.to_s
  end

  def test_nested_convert_ignores_output
    cmd = convert(to: 'baz') do
      convert('foo', to: 'nowhere') { set :bar }
    end

    assert_equal 'convert foo -bar baz', cmd.to_s
  end

  def test_multi_image_nested_convert
    cmd = convert('foo', to: 'bar') do
      convert('qux') do
        set '+asdf'
        set '+fdsa'
      end

      image 'bleh'
      set '-resize'
    end

    assert_equal 'convert foo ( qux +asdf +fdsa ) bleh -resize bar', cmd.to_s
  end

  def test_convert_composition
    complex_image = convert('image1') do
      set '+image1-x'
      set '+image1-y'
    end

    cmd = convert('image2', to: 'bar') do
      image complex_image
      image 'image3'
      set '-setting-for-all-images'
    end

    assert_equal 'convert image2 ( image1 +image1-x +image1-y ) image3 '\
      '-setting-for-all-images bar', cmd.to_s
  end

  def test_convert_double_nesting_with_composition
    complex_image = convert('image1', to: 'nowhere') do
      convert('image2', to: 'nowhere') do
        convert('image3') do
          image 'image4'
          set :option, 'qux'
        end

        image 'image5'
        set '+option'
      end
    end

    cmd = convert('image6') do
      image complex_image
      image 'image7'
      set '-option', 'quux'
    end

    assert_equal 'convert image6 ( image1 ( image2 ( image3 image4 -option '\
      'qux ) image5 +option ) ) image7 -option quux miff:-', cmd.to_s
  end

  def test_convert_reusing_variable
    cmd = 'foo'
    cmd = convert('bar') { set(:arg); image(cmd) }
    assert_equal 'convert bar -arg foo miff:-', cmd.to_s
  end

  def test_inject_image_into_convert
    sample = image do
      set   :size, '400x400'
      image 'tile:granite:'
      set '-brightness-contrast', '38x-33'
      set :blur, '0x0.5'
    end

    cmd = convert do
      set '-foo'
      image sample
      set '-bar'
    end

    assert_equal 'convert -foo ( -size 400x400 tile:granite: ' +
      '-brightness-contrast 38x-33 -blur 0x0.5 ) -bar miff:-', cmd.to_s
  end

  def test_inject_image_into_convert_as_argument
    sample = image do
      set   :size, '400x400'
      image 'tile:granite:'
      append '-brightness-contrast', '38x-33'
      append :blur, '0x0.5'
    end

    cmd = convert(sample)
    assert_equal 'convert -size 400x400 tile:granite: -brightness-contrast ' +
      '38x-33 -blur 0x0.5 miff:-', cmd.to_s
  end

  def test_declare_image_inside_convert
    cmd = convert do
      set '-foo'
      image do
        set   :size, '400x400'
        image 'tile:granite:'
        append '-brightness-contrast', '38x-33'
        append :blur, '0x0.5'
      end
      set '-bar'
    end

    assert_equal 'convert -foo ( -size 400x400 tile:granite: ' +
      '-brightness-contrast 38x-33 -blur 0x0.5 ) -bar miff:-', cmd.to_s
  end

  def test_convert_as_image_object
    sample = convert('foo', to: 'bar') do
      set :baz
    end

    cmd = convert do
      image do
        set :setting
        append :operation
        image sample
      end
    end

    assert_equal 'convert -setting ( foo -baz ) -operation miff:-',
      cmd.to_s
  end
end
