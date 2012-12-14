require 'skeptick/helper'
require 'skeptick/pipe'

module Skeptick
  class Wrapper
    include Skeptick::Helper

    def initialize(context, *args, &blk)
      @context = context
      @inner = false
      @write = nil
      @ops = []
      @images = []
      @parts = []

      @args = args.dup
      @options = extract_options!(@args)
      @to = @options[:to] || :pipe

      _setup
      instance_eval(&blk) if block_given?
      _finalize
    end

    def convert(*args, &blk)
      @images << Convert.new(@context, *args, &blk)
    end

    def compose(*args, &blk)
      @images << Compose.new(@context, *args, &blk)
    end

    def image(obj)
      @images << obj
      @images.size - 1
    end

    def with(*args)
      @ops << args.join(' ')
    end

    def clone(*args)
      obj = (args.size < 2 ? args.first : args)
      obj ? "-clone #{_obj_to_index_range_list(obj)}" : '+clone'
    end

    def delete(*args)
      obj = (args.size < 2 ? args.first : args)
      @images << (obj ? "-delete #{_obj_to_index_range_list(obj)}" : '+delete')
    end

    def swap(*args)
      @images << if args.empty?
        '+swap'
      elsif args.size == 2
        "-swap #{args.join(', ')}"
      else
        raise ArgumentError,
          "wrong number of arguments (#{args.size} for 0, 2)"
      end
    end

    def write(path)
      @write = path
    end

    # def store_images(label)
    #   if label == :pipe
    #     raise 'label :pipe is reserved'
    #   else
    #     @images << "-write mpr:#{label}"
    #   end
    # end

    # def load_images(label)
    #   @images << "mpr:#{label}"
    # end

    def to_s
      _parts.map(&:to_s).join(' ')
    end

    def run
      Skeptick.log("Skeptick: #{_command}")
      system("cd #{Skeptick.cd_path} && #{_command}")
    end

    def method_missing(*args, &blk)
      @context.send(*args, &blk)
    end

    def _obj_to_index_range_list(obj)
      case obj
      when Integer, String
        obj
      when Range
        "#{obj.min}-#{obj.max}"
      when Array
        obj.join(',')
      else
        raise "invalid sequence reference"
      end
    end

    def _parts
      _parse_pipes(
        [
          _inner? ? '(' : 'convert',
          *@parts,
          _inner? ? ')' : @to
        ]
      )
    end

    def _piping?
      !_inner? && _parts.last == Pipe::PATH
    end

    def _inner?
      @inner
    end

    def _inner!
      @inner = true
    end

    def _parse_pipes(paths)
      paths.map do |path|
        path == :pipe ? Pipe::PATH : path
      end
    end

    def _process_images(images)
      images.each do |image|
        image._inner! if image.respond_to?(:_inner!)
      end

      _parse_pipes(images)
    end

    def _to=(to)
      if _inner?
        raise 'cannot assign output to parentheses-wrapped image conversion'
      else
        @to = to
      end
    end

    def _command
      to_s.shellsplit.shelljoin
    end
  end
end
