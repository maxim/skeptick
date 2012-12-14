require 'skeptick/wrapper'

module Skeptick
  class Wrapper
    class Compose < Wrapper
      def _setup
        @blending = @args.shift.to_s
        @parts += _parse_pipes(@args)
      end

      def _finalize
        @parts += _process_images(@images)
        @parts << '-compose' << @blending
        @parts += @ops
        @parts << '-composite'
        @parts << "-write #{@write}" if @write
      end
    end
  end
end
