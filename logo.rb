require_relative 'lib/skeptick'

include Skeptick

image_size = '400x120'

paper = rounded_corners_image(size: image_size, radius: 25) do
  set   :size, image_size
  image 'tile:granite:'
  apply '-brightness-contrast', '38x-33'
  apply :blur, '0x0.5'
end

left, top = 8, 80
text = image do
  canvas :none, size: '395x110'
  font   'Handwriting - Dakota Regular'
  set    :pointsize, 90
  set    :fill, 'gradient:#37e-#007'
  write  'Skeptick', left: left, top: top
  apply  :blur, '0x0.7'
end

bezier = \
  "#{left + 17 }, #{top + 17}   #{left + 457}, #{top - 13} " +
  "#{left + 377}, #{top + 27}   #{left + 267}, #{top + 27}"

curve = image do
  canvas :none, size: '395x110'
  set    :strokewidth, 2
  set    :stroke, 'gradient:#37e-#007'
  draw   "fill none bezier #{bezier}"
end

result_path = "#{File.dirname(__FILE__)}/logo.png"

torn = torn_paper_image(
  paper * (text + curve),
  spread: 50,
  blur:   '3x10'
)

logo = convert(torn, to: result_path)
logo.build
# system "osascript refresh_preview.scpt"
