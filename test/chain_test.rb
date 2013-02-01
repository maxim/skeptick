require_relative 'test_helper'

class ChainTest < Skeptick::TestCase
  include Skeptick

  def test_dsl_methods_available
    assert_respond_to self, :chain
  end

  def test_chaining_two_converts
    cmd = chain do
      convert('foo')
      convert(:pipe)
    end

    assert_equal 'convert foo miff:- | convert miff:- miff:-', cmd.to_s
  end

  def test_chaining_two_converts_to_destination
    cmd = chain(to: 'baz') do
      convert('foo')
      convert(:pipe)
    end

    assert_equal 'convert foo miff:- | convert miff:- baz', cmd.to_s
  end

  def test_last_convert_destination_prevails
    cmd = chain(to: 'baz') do
      convert('foo')
      convert(:pipe, to: 'qux')
    end

    assert_equal 'convert foo miff:- | convert miff:- qux', cmd.to_s
  end

  def test_pipe_or_returns_pipe_if_piping
    cmd = chain do
      convert('foo')
      convert(pipe_or('bar'))
    end

    assert_equal 'convert foo miff:- | convert miff:- miff:-', cmd.to_s
  end

  def test_pipe_or_returns_path_if_not_piping
    cmd = chain { convert(pipe_or('foo')) }
    assert_equal 'convert foo miff:-', cmd.to_s
  end

  def test_lvars_from_external_context_are_accessible
    foo = 'foo'
    cmd = chain { convert(foo) }
    assert_equal 'convert foo miff:-', cmd.to_s
  end

  def test_methods_from_external_context_are_accessible
    context = Class.new do
      include Skeptick
      def foo; 'foo' end
      def cmd; chain { convert(foo) } end
    end

    assert_equal 'convert foo miff:-', context.new.cmd.to_s
  end

  def test_complex_piping_case
    cmd = chain(to: 'foo') do
      convert('resized_design', 'mask') do
        set '-geometry', '-left-top'
        set '-brightness-contrast',  '-12x20'
      end

      convert('foo') do
        convert('qux') do
          set '+asdf'
          set '+fdsa'
        end

        image 'bleh'
        set '-resize'
      end

      convert('paper_path', pipe_or('paper_path')) do
        set '-geometry +left+top'
      end
    end

    assert_equal 'convert resized_design mask -geometry -left-top ' +
      '-brightness-contrast -12x20 miff:- | convert foo ' +
      '\( qux \+asdf \+fdsa \) bleh -resize miff:- | convert paper_path ' +
      'miff:- -geometry \+left\+top foo', cmd.to_s
  end
end
