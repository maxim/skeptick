require_relative '../test_helper'
require 'skeptick/sugar/rounded_corners_image'

class RoundedCornersImageTest < Skeptick::TestCase
  include Skeptick

  def test_rounded_corners_image_without_block_and_radius
    img = rounded_corners_image('foo', size: '200x300')

    assert_equal 'convert foo ( +clone '\
      '-draw roundrectangle 1,1 200,300 15,15 ) -compose dstin '\
      '-composite miff:-', img.to_s
  end

  def test_rounded_corners_image_with_block_and_radius
    img = rounded_corners_image(size: '200x300', radius: 20) do
      image 'tile:granite:'
      append '-brightness-contrast', '38x-33'
    end

    assert_equal 'convert ( tile:granite: -brightness-contrast 38x-33 )'\
      ' ( +clone -draw roundrectangle 1,1 '\
      '200,300 20,20 ) -compose dstin -composite miff:-', img.to_s
  end

  def test_nested_rounded_corners_image
    cmd = convert(to: 'bar') do
      rounded_corners_image('foo', size: '200x300', radius: 5)
    end

    assert_equal 'convert foo ( +clone '\
      '-draw roundrectangle 1,1 200,300 5,5 ) -compose '\
      'dstin -composite bar', cmd.to_s
  end

  def test_nested_rounded_corners_image_via_lvar_arg
    img = rounded_corners_image('foo', size: '200x300', radius: 5)
    cmd = convert(img, to: 'bar')

    assert_equal 'convert foo ( +clone '\
      '-draw roundrectangle 1,1 200,300 5,5 ) -compose '\
      'dstin -composite bar', cmd.to_s
  end

  def test_nested_rounded_corners_image_via_lvar_in_block
    img = rounded_corners_image('foo', size: '200x300', radius: 5)
    cmd = convert(to: 'bar') { image(img) }

    assert_equal 'convert foo ( +clone '\
      '-draw roundrectangle 1,1 200,300 5,5 ) -compose '\
      'dstin -composite bar', cmd.to_s
  end
end
