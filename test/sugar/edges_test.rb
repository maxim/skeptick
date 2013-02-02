require_relative '../test_helper'
require 'skeptick/sugar/edges'

class EdgesTest < Skeptick::TestCase
  include Skeptick

  def test_rounded_corners_image_without_block_and_radius
    img = rounded_corners_image('foo', size: '200x300')

    assert_equal 'convert foo ( +clone -alpha transparent -background none ' +
      '-draw roundrectangle\ 1,1\ 200,300\ 15,15 ) -alpha set -compose dstin ' +
      '-composite miff:-', img.to_s
  end

  def test_rounded_corners_image_with_block_and_radius
    img = rounded_corners_image(size: '200x300', radius: 20) do
      image 'tile:granite:'
      apply '-brightness-contrast', '38x-33'
    end

    assert_equal 'convert tile:granite: -brightness-contrast 38x-33 ( +clone ' +
      '-alpha transparent -background none -draw roundrectangle\ 1,1\ ' +
      '200,300\ 20,20 ) -alpha set -compose dstin -composite miff:-', img.to_s
  end

  def test_nested_rounded_corners_image
    cmd = convert(to: 'bar') do
      rounded_corners_image('foo', size: '200x300', radius: 5)
    end

    assert_equal 'convert ( foo ( +clone -alpha transparent -background none ' +
      '-draw roundrectangle\\ 1,1\\ 200,300\\ 5,5 ) -alpha set -compose ' +
      'dstin -composite ) bar', cmd.to_s
  end

  def test_nested_rounded_corners_image_via_lvar_arg
    img = rounded_corners_image('foo', size: '200x300', radius: 5)
    cmd = convert(img, to: 'bar')

    assert_equal 'convert ( foo ( +clone -alpha transparent -background none ' +
      '-draw roundrectangle\\ 1,1\\ 200,300\\ 5,5 ) -alpha set -compose ' +
      'dstin -composite ) bar', cmd.to_s
  end

  def test_nested_rounded_corners_image_via_lvar_in_block
    img = rounded_corners_image('foo', size: '200x300', radius: 5)
    cmd = convert(to: 'bar') { image(img) }

    assert_equal 'convert ( foo ( +clone -alpha transparent -background none ' +
      '-draw roundrectangle\\ 1,1\\ 200,300\\ 5,5 ) -alpha set -compose ' +
      'dstin -composite ) bar', cmd.to_s
  end

  def test_torn_paper_image_without_block_spread_blur_threshold
    img = torn_paper_image('foo')
    assert_equal 'convert foo ( +clone -alpha extract -virtual-pixel black ' +
      '-spread 1 -blur 0x.7 -threshold 50% ) -alpha off ' +
      '-compose copy_opacity -composite miff:-', img.to_s
  end

  def test_torn_paper_image_with_block_spread_blur_threshold
    img = torn_paper_image('foo', spread: 17, blur: '1x4', threshold: 70) do
      image 'tile:granite:'
      apply '-brightness-contrast', '38x-33'
    end

    assert_equal 'convert tile:granite: -brightness-contrast 38x-33 ( +clone ' +
      '-alpha extract -virtual-pixel black -spread 17 -blur 1x4 -threshold ' +
      '70% ) -alpha off -compose copy_opacity -composite miff:-', img.to_s
  end

  def test_nested_torn_paper_image
    cmd = convert(to: 'bar') do
      torn_paper_image('foo')
    end

    assert_equal 'convert ( foo ( +clone -alpha extract -virtual-pixel black ' +
      '-spread 1 -blur 0x.7 -threshold 50% ) -alpha off -compose ' +
      'copy_opacity -composite ) bar', cmd.to_s
  end

  def test_nested_torn_paper_image_via_lvar_arg
    img = torn_paper_image('foo')
    cmd = convert(img, to: 'bar')

    assert_equal 'convert ( foo ( +clone -alpha extract -virtual-pixel black ' +
      '-spread 1 -blur 0x.7 -threshold 50% ) -alpha off -compose ' +
      'copy_opacity -composite ) bar', cmd.to_s
  end

  def test_nested_torn_paper_image_via_lvar_in_block
    img = torn_paper_image('foo')
    cmd = convert(to: 'bar') { image(img) }

    assert_equal 'convert ( foo ( +clone -alpha extract -virtual-pixel black ' +
      '-spread 1 -blur 0x.7 -threshold 50% ) -alpha off -compose ' +
      'copy_opacity -composite ) bar', cmd.to_s
  end
end
