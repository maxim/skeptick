require 'skeptick/helper'
require 'skeptick/convert'
require 'skeptick/chain'
require 'skeptick/image/dsl_context'

module Skeptick
  class Image
    attr_accessor :prepends, :appends

    def initialize(context, obj = nil, &blk)
      @context = context
      @obj = obj || blk
      reset
    end

    def set(*args)
      @prepends << Helper.process_args(*args)
    end

    def apply(*args)
      @appends << Helper.process_args(*args)
    end

    def image(obj, &blk)
      @image = Image.new(@context, obj, &blk)
    end

    def convert(*args, &blk)
      @image = Convert.new(@context, *args, &blk).become_inner
    end

    def process_method_missing(*args, &blk)
      @context.send(*args, &blk)
    end

    def to_s
      parts.join(' ')
    end

    def inspect
      "Skeptick::Image(#{to_s})"
    end

    def parts
      case @obj
      when :pipe   then [ Chain::PIPE ]
      when Convert then @obj.become_inner.parts
      when Image   then @obj.parts
      when Array   then @obj
      when Proc    then build_parts
      else         [ @obj ]
      end
    end

    private

    def build_parts
      reset
      DslContext.new(self).instance_eval(&@obj)
      [*@prepends, @image, *@appends].compact
    end

    def reset
      @image    = nil
      @prepends = []
      @appends  = []
    end
  end
end
