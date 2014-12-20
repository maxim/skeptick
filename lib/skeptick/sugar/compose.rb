module Skeptick
  class Compose < Convert
    def initialize(context, *args, &blk)
      @blending = args.shift.to_s
      super
    end

    def setup_appends
      [:compose, @blending, :composite]
    end
  end

  class Convert
    def +(other)
      Compose.new(@context, :over, self, other)
    end

    def -(other)
      Compose.new(@context, :dstout, self, other)
    end

    def *(other)
      Compose.new(@context, :multiply, self, other)
    end

    def /(other)
      Compose.new(@context, :divide, self, other)
    end

    def &(other)
      Compose.new(@context, :dstin, self, other).tap do |c|
        c.subjects << :alpha << 'Set'
      end
    end

    def |(other)
      Compose.new(@context, :dstover, self, other)
    end
  end

  class DslContext
    def compose(blending, *args, &blk)
      @convert.subjects << Compose.new(self, blending, *args, &blk)
    end
  end

  def compose(blending, *args, &blk)
    Compose.new(self, blending, *args, &blk)
  end
end
