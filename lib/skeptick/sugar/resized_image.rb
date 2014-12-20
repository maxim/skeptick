require 'skeptick/sugar/geometry'

module Skeptick
  module ResizedImage
    def resized_image(path, options = {})
      image("#{path}[#{geometry(options)}]")
    end
  end

  include ResizedImage

  class DslContext
    include ResizedImage
  end
end
