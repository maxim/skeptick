require 'skeptick/helper'

module Skeptick
  class Pipe
    include Skeptick::Helper

    PATH = 'miff:-'

    def initialize(context, *args, &blk)
      options = extract_options!(args)
      @to = options[:to]
      @context = context
      @wrappers = []
      instance_eval(&blk)

      if @wrappers.size > 0 && @to && _piping?
        @wrappers.last._to = @to
      end
    end

    def convert(*args, &blk)
      @wrappers << Wrapper::Convert.new(@context, *args, &blk)
    end

    def compose(*args, &blk)
      @wrappers << Wrapper::Compose.new(@context, *args, &blk)
    end

    def pipe_or(path)
      _piping? ? :pipe : path
    end

    def method_missing(*args, &blk)
      @context.send(*args, &blk)
    end

    def to_s
      @wrappers.map(&:to_s).join(' | ')
    end

    def run
      Skeptick.log("Skeptick: #{_command}")
      system("cd #{Skeptick.cd_path} && #{_command}")
    end

    def _piping?
      @wrappers.last && @wrappers.last._piping?
    end

    def _command
      @wrappers.map(&:_command).join(' | ')
    end
  end
end
