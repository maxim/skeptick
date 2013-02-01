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
        @convert.convert(*args, &blk)
      end

      def image(obj = nil, &blk)
        @convert.image(obj, &blk)
      end

      def method_missing(*args, &blk)
        @convert.process_method_missing(*args, &blk)
      end
    end
  end
end
