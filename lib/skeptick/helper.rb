module Skeptick
  module Helper
    module_function

    def extract_options!(array)
      array.last.is_a?(Hash) ? array.pop : {}
    end

    def object_to_index_range_list(obj)
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

    def process_args(*args)
      args.map{ |arg| arg.is_a?(Symbol) ? "-#{arg.to_s}" : arg }.join(' ')
    end
  end
end
