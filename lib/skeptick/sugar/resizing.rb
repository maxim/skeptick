require 'skeptick/sugar/geometry'

module Skeptick
  module Sugar
    module Resizing
      def resized_image(path, options = {})
        image("#{path}[#{geometry(options)}]")
      end
    end
  end

  include Sugar::Resizing

  class   Image::DslContext; include Sugar::Resizing end
  class Convert::DslContext; include Sugar::Resizing end
end
