module Skeptick
  class DslContext
    def initialize(convert)
      @convert = convert
    end

    def prepend(*args)
      @convert.prepends.push(*args)
    end

    def set(*args)
      @convert.subjects.push(*args)
    end

    def append(*args)
      @convert.appends.push(*args)
    end

    def convert(*args, &blk)
      @convert.subjects << Convert.new(self, *args, &blk)
    end
    alias_method :image, :convert

    def method_missing(*args, &blk)
      @convert.context.send(*args, &blk)
    end

    def respond_to_missing?(meth, include_all)
      @convert.context.respond_to?(meth, include_all)
    end
  end
end
