require 'skeptick/helper'
require 'skeptick/convert'
require 'skeptick/chain/dsl_context'
require 'skeptick/command'

module Skeptick
  class Chain
    include Command::Executable

    PIPE = 'miff:-'

    def initialize(context, *args, &blk)
      options = Helper.extract_options!(args)
      @to = options[:to]
      @context = context
      @block = blk
      reset
    end

    def convert(*args, &blk)
      @executables << Convert.new(@context, *args, &blk)
    end

    def piping?
      @executables.last && @executables.last.piping?
    end

    def process_method_missing(*args, &blk)
      @context.send(*args, &blk)
    end

    def to_s
      process_dsl
      @executables.map(&:command).join(' | ')
    end

    def inspect
      "Skeptick::Chain(#{to_s})"
    end

    private
      def reset
        @executables = []
      end

      def process_dsl
        reset
        DslContext.new(self).instance_eval(&@block)

        if @executables.size > 0 && @to && piping?
          @executables.last.destination = @to
        end
      end
  end
end
