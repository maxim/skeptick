require 'skeptick/helper'
require 'skeptick/convert'
require 'skeptick/pipe'
require 'skeptick/image/dsl_context'

module Skeptick
  class Image
    def initialize(context, obj = nil, &blk)
      @context = context
      @obj = obj || blk
      reset
    end

    attr_accessor :prepends, :appends
    def prepend(*args); @prepends << Helper.process_args(*args) end
    def append(*args);  @appends  << Helper.process_args(*args) end

    def set_image(obj, &blk)
      @image = Image.new(@context, obj, &blk)
    end

    def set_nested_convert(*args, &blk)
      @image = Convert.new(@context, *args, &blk).become_inner
    end

    def process_method_missing(*args, &blk)
      @context.send(*args, &blk)
      # result = @context.send(*args, &blk)

      # case result
      #   # Do we actually need these become_inner up in set_nested_convert,
      #   # right here, and down in #to_s?
      #   when Convert then @image = result.become_inner
      #   when Image   then @image = result
      #   else result
      # end
    end

    def to_s
      reset

      case @obj
        when :pipe;   Pipe::PATH
        when Convert; @obj.become_inner.to_s
        when Array;   @obj.join(' ')
        when Proc;    parts.join(' ')
        else          @obj.to_s
      end
    end

    def parts
      if @obj.is_a?(Proc)
        reset
        DslContext.new(self).instance_eval(&@obj)
        [*@prepends, @image, *@appends]
      else
        []
      end
    end

    private
      def reset
        @image    = nil
        @prepends = []
        @appends  = []
      end
  end
end
