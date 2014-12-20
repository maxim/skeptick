$: << 'lib'
require 'skeptick'
puts "Skeptick #{Skeptick::VERSION}"

include Skeptick

image_size = '400x120'

paper = rounded_corners_image(size: image_size, radius: 25) do
  set   :size, image_size
  image 'tile:granite:'
  set '-brightness-contrast', '38x-25'
  set :blur, '0x0.5'
end

left, top = 8, 80
text = image do
  canvas :none, size: '395x110'
  font   'Handwriting - Dakota'
  set    :pointsize, 90
  set    :fill, 'gradient:#37e-#007'
  text   'Skeptick', left: left, top: top
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

final = torn_paper_image \
  paper * (text + curve),
  spread: 50,
  blur:   '3x10'

logo_script = convert(final, to: result_path)
puts logo_script.to_s
logo_script.run
# system "osascript refresh_preview.scpt"
