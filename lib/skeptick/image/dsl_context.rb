module Skeptick
  class Image
    class DslContext
      def initialize(image)
        @image = image
      end

      def set(*args)
        @image.set(*args)
      end

      def apply(*args)
        @image.apply(*args)
      end

      def image(obj)
        @image.image(obj)
      end

      def convert(*args, &blk)
        @image.convert(*args, &blk)
      end

      def method_missing(*args, &blk)
        @image.process_method_missing(*args, &blk)
      end
    end
  end
end
