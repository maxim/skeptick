require 'skeptick/wrapper'

module Skeptick
  class Wrapper
    class Convert < Wrapper
      def _setup
        @parts += _parse_pipes(@args)
      end

      def _finalize
        @parts += _process_images(@images)
        @parts += @ops
        @parts << "-write #{@write}" if @write
      end
    end
  end
end
