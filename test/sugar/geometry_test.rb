require_relative '../test_helper'
require 'skeptick/sugar/geometry'

class GeometryTest < Skeptick::TestCase
  include Skeptick

  def test_blank_geometry
    assert_equal '', geometry
  end

  def test_geometry_with_size
    assert_equal '100x200', geometry(size: '100x200')
  end

  def test_geometry_with_width
    assert_equal '100x', geometry(width: 100)
  end

  def test_geometry_with_height
    assert_equal 'x200', geometry(height: 200)
  end

  def test_geometry_with_width_and_height
    assert_equal '100x200', geometry(width: 100, height: 200)
  end

  def test_geometry_with_left
    assert_equal '+5+0', geometry(left: 5)
  end

  def test_geometry_with_top
    assert_equal '+0+7', geometry(top: 7)
  end

  def test_geometry_with_left_top
    assert_equal '+5+7', geometry(left: 5, top: 7)
  end

  def test_geometry_with_negative_left
    assert_equal '-5+7', geometry(left: -5, top: 7)
  end

  def test_geometry_with_negative_left_top
    assert_equal '-5-7', geometry(left: -5, top: -7)
  end

  def test_geometry_with_left_width_height
    assert_equal '100x200+5+0', geometry(left: 5, width: 100, height: 200)
  end

  def test_geometry_with_top_width_height
    assert_equal '100x200+0+7', geometry(top: 7, width: 100, height: 200)
  end

  def test_geometry_with_left_top_width_height
    assert_equal '100x200+5-7',
      geometry(left: 5, top: -7, width: 100, height: 200)
  end

  def test_geometry_with_percentage
    assert_equal '100x200%',
      geometry(width: 100, height: 200, percentage: true)
  end

  def test_geometry_with_exact
    assert_equal '100x200!', geometry(width: 100, height: 200, exact: true)
  end

  def test_geometry_with_expand_only
    assert_equal '100x200<',
      geometry(width: 100, height: 200, expand_only: true)
  end

  def test_geometry_with_shrink_only
    assert_equal '100x200>',
      geometry(width: 100, height: 200, shrink_only: true)
  end

  def test_everything_together
    assert_equal '100x200-7+5%!<>',
      geometry(
        width: 100,
        height: 200,
        left: -7,
        top: 5,
        percentage: true,
        exact: true,
        expand_only: true,
        shrink_only: true
      )
  end
end
