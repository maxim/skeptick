require 'skeptick/sugar/compose'
require 'skeptick/sugar/format'
require 'skeptick/sugar/draw'

module Skeptick
  module RoundedCornersImage
    def rounded_corners_image(*args, &blk)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      radius = opts[:radius] || 15
      size   = opts[:size]
      width  = opts[:width]
      height = opts[:height]

      if size
        width, height = size.split('x').map(&:to_i)
      end

      border = if width && height
        "roundrectangle 1,1 #{width},#{height} #{radius},#{radius}"
      else
        Convert.new(self, *args, to: 'info:') do
          format "roundrectangle 1,1 %[fx:w], %[fx:h] #{radius},#{radius}"
        end.run.strip
      end

      compose(:dstin, *args) do
        convert(&blk) if block_given?

        convert do
          set '+clone'
          set :draw, border
        end
      end
    end
  end

  class DslContext
    include RoundedCornersImage
  end

  include RoundedCornersImage
end
