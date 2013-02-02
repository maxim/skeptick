require 'skeptick/sugar/composition'
require 'skeptick/sugar/formatting'

module Skeptick
  module Sugar
    module Edges
      def rounded_corners_image(image = nil, options = {}, &blk)
        options = image.is_a?(Hash) ? image : options
        radius = options[:radius] || 15
        width, height = options.values_at(:width, :height)

        if options[:size]
          width, height = *options[:size].split('x').map(&:to_i)
        end

        if block_given?
          image = Image.new(self, &blk)
        end

        border = if width && height
          "roundrectangle 1,1 #{width},#{height} #{radius},#{radius}"
        else
          convert(image, to: 'info:') do
            format "roundrectangle 1,1 %[fx:w], %[fx:h] #{radius},#{radius}"
          end.execute.strip
        end

        compose(:dstin, image) do
          convert do
            set '+clone'
            set :alpha, 'transparent', :background, 'none'
            draw border
          end

          set :alpha, 'set'
        end
      end

      def torn_paper_image(image = nil, options = {}, &blk)
        options   = image.is_a?(Hash) ? image : options

        spread    = options[:spread]    || 1
        blur      = options[:blur]      || '0x.7'
        threshold = options[:threshold] || 50

        if block_given?
          image = Image.new(self, &blk)
        end

        compose(:copy_opacity, image) do
          convert do
            set '+clone'
            apply :alpha, 'extract'
            apply '-virtual-pixel', 'black'
            apply :spread, spread
            apply :blur, blur
            apply :threshold, "#{threshold}%"
          end

          apply :alpha, 'off'
        end
      end
    end
  end

  include Sugar::Edges

  class   Image::DslContext; include Sugar::Edges end
  class Convert::DslContext; include Sugar::Edges end
end
