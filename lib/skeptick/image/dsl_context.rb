module Skeptick
  class Image
    class DslContext
      def initialize(image)
        @image = image
      end

      def set(*args)
        @image.prepend(*args)
      end

      def apply(*args)
        @image.append(*args)
      end

      def image(obj = nil, &blk)
        @image.set_image(obj, &blk)
      end

      def convert(*args, &blk)
        @image.set_nested_convert(*args, &blk)
      end

      def method_missing(*args, &blk)
        @image.process_method_missing(*args, &blk)
      end
    end
  end
end
