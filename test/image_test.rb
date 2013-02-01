require_relative 'test_helper'

class ImageTest < Skeptick::TestCase
  include Skeptick

  def test_dsl_method_available
    assert_respond_to self, :image
  end

  def test_set_prepends_to_image_segment
    cmd = convert do
      image do
        image 'bar'
        set '-foo'
      end
    end

    assert_equal 'convert -foo bar miff:-', cmd.to_s
  end

  def test_apply_appends_to_image_segment
    cmd = convert do
      image do
        apply '-foo'
        image 'bar'
      end
    end

    assert_equal 'convert bar -foo miff:-', cmd.to_s
  end

  def test_lvars_from_external_context_are_accessible
    foo = '-test'

    cmd = convert do
      image do
        apply foo
        image 'bar'
      end
    end

    assert_equal 'convert bar -test miff:-', cmd.to_s
  end

  def test_methods_from_external_context_are_accessible
    context = Class.new do
      include Skeptick
      def foo; :foo end
      def cmd
        convert do
          image do
            apply foo
            image 'bar'
          end
        end
      end
    end

    assert_equal 'convert bar -foo miff:-', context.new.cmd.to_s
  end

  def test_inject_image_into_convert
    sample = image do
      set   :size, '400x400'
      image 'tile:granite:'
      apply '-brightness-contrast', '38x-33'
      apply :blur, '0x0.5'
    end

    cmd = convert do
      set '-foo'
      image sample
      set '-bar'
    end

    assert_equal 'convert -foo -size 400x400 tile:granite: ' +
      '-brightness-contrast 38x-33 -blur 0x0.5 -bar miff:-', cmd.to_s
  end

  def test_inject_image_into_convert_as_argument
    sample = image do
      set   :size, '400x400'
      image 'tile:granite:'
      apply '-brightness-contrast', '38x-33'
      apply :blur, '0x0.5'
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
        apply '-brightness-contrast', '38x-33'
        apply :blur, '0x0.5'
      end
      set '-bar'
    end

    assert_equal 'convert -foo -size 400x400 tile:granite: ' +
      '-brightness-contrast 38x-33 -blur 0x0.5 -bar miff:-', cmd.to_s
  end

  def test_nested_image
    sample = image do
      set :foo
      image 'bar'
      apply :baz
    end

    cmd = convert do
      image do
        set :size, '400x400'
        image sample
        apply '-brightness-contrast', '38x-33'
        apply :blur, '0x0.5'
      end
    end

    assert_equal 'convert -size 400x400 -foo bar -baz -brightness-contrast ' +
      '38x-33 -blur 0x0.5 miff:-', cmd.to_s
  end

  def test_convert_as_image_object
    sample = convert('foo', to: 'bar') do
      set :baz
    end

    cmd = convert do
      image do
        set '-setting'
        image sample
        apply '-operation'
      end
    end

    assert_equal 'convert -setting ( foo -baz ) -operation miff:-',
      cmd.to_s
  end
end
