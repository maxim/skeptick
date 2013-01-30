module Skeptick
  class Convert
    class DslContext
      def initialize(convert)
        @convert = convert
      end

      def set(*args)
        @convert.set(*args)
      end
      alias_method :apply, :set
      alias_method :with,  :set

      def convert(*args, &blk)
        @convert.add_nested_convert(*args, &blk)
      end

      def image(obj = nil, &blk)
        @convert.add_image(obj, &blk)
      end
    end
  end
end
