require 'skeptick/helper'
require 'skeptick/image'
require 'skeptick/pipe'
require 'skeptick/convert/dsl_context'
require 'skeptick/execution'

module Skeptick
  class Convert
    def initialize(context, *args, &blk)
      @context = context
      @options = Helper.extract_options!(args)
      @args    = args.map {|a| Image.new(@context, a)}
      @block   = blk
      @to      = parse_pipe(@options[:to])
      @inner   = false

      @beginning = nil
      @ending    = nil
      @prepends  = []
      @appends   = []

      reset
    end

    attr_accessor :prepends, :appends
    def prepend(*args); @prepends << Helper.process_args(*args) end
    def append(*args);  @appends  << Helper.process_args(*args) end
    def set(*args);     @objects  << Helper.process_args(*args) end

    def add_nested_convert(*args, &blk)
      Convert.new(@context, *args, &blk).tap do |c_obj|
        @objects << Image.new(@context, c_obj)
      end
    end

    def add_image(obj = nil, &blk)
      @objects << Image.new(@context, obj, &blk)
    end

    def destination=(to)
      if inner?
        raise 'cannot assign output to parentheses-wrapped image conversion'
      else
        @to = to
      end
    end

    def become_inner
      @inner = true
      self
    end

    def parts
      reset
      @objects = []
      DslContext.new(self).instance_eval(&@block) if @block
      wrap
      [@beginning, *@prepends, *@args, *@objects, *@appends, @ending]
    end

    def to_s
      parts.join(' ')
    end

    def process_method_missing(*args, &blk)
      @context.send(*args, &blk)

      # result = @context.send(*args, &blk)

      # case result
      #   when Convert then image(result)
      #   when Image   then @objects << (result)
      #   else result
      # end
    end

    def execute
      Execution.new(self).run
    end
    alias_method :build, :execute

    private
      def reset
        @objects = []
      end

      def inner?
        @inner
      end

      def piping?
        !inner? && parts.last == Pipe::PATH
      end

      def wrap
        @beginning = inner? ? '(' : 'convert'
        @ending    = inner? ? ')' : @to || Pipe::PATH
      end

      def parse_pipe(obj)
        obj == :pipe ? Pipe::PATH : obj
      end
  end
end
