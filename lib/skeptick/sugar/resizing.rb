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
end
