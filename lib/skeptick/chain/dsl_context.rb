module Skeptick
  class Chain
    class DslContext
      def initialize(chain)
        @chain = chain
      end

      def convert(*args, &blk)
        @chain.convert(*args, &blk)
      end

      def pipe_or(path)
        @chain.piping? ? :pipe : path
      end

      def method_missing(*args, &blk)
        @chain.process_method_missing(*args, &blk)
      end
    end
  end
end
