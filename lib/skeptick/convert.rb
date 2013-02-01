require 'skeptick/helper'
require 'skeptick/image'
require 'skeptick/chain'
require 'skeptick/convert/dsl_context'
require 'skeptick/command'

module Skeptick
  class Convert
    include Command::Executable

    attr_accessor :prepends, :appends

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

    def prepend(*args)
      @prepends << Helper.process_args(*args)
    end

    def append(*args)
      @appends << Helper.process_args(*args)
    end

    def set(*args)
      @objects << Helper.process_args(*args)
    end
    alias_method :apply, :set
    alias_method :with,  :set


    def convert(*args, &blk)
      Convert.new(@context, *args, &blk).tap do |c_obj|
        @objects << Image.new(@context, c_obj)
      end
    end

    def image(obj = nil, &blk)
      @objects << Image.new(@context, obj, &blk)
    end

    def destination=(to)
      if inner?
        raise 'cannot assign output to parentheses-wrapped image conversion'
      else
        @to = to
      end
    end

    def piping?
      !inner? && parts.last == Chain::PIPE
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
      [@beginning, *@prepends, *@args, *@objects, *@appends, @ending].compact
    end

    def to_s
      parts.join(' ')
    end

    def inspect
      "Skeptick::Convert(#{to_s})"
    end

    def process_method_missing(*args, &blk)
      @context.send(*args, &blk)
    end

    private
      def reset
        @objects = []
      end

      def inner?
        @inner
      end

      def wrap
        @beginning = inner? ? '(' : 'convert'
        @ending    = inner? ? ')' : @to || Chain::PIPE
      end

      def parse_pipe(obj)
        obj == :pipe ? Chain::PIPE : obj
      end
  end
end
