module Skeptick
  module Sugar
    module SequenceManipulation
      def clone(*args)
        obj = (args.size < 2 ? args.first : args)
        set(
          if obj
            "-clone #{Helper.object_to_index_range_list(obj)}"
          else
            '+clone'
          end
        )
      end

      def delete(*args)
        obj = (args.size < 2 ? args.first : args)
        set(
          if obj
            "-delete #{Helper.object_to_index_range_list(obj)}"
          else
            '+delete'
          end
        )
      end

      def swap(*args)
        set(
          if args.empty?
            '+swap'
          elsif args.size == 2
            "-swap #{args.join(',')}"
          else
            raise ArgumentError,
              "wrong number of arguments (#{args.size} for 0, 2)"
          end
        )
      end
    end
  end

  class   Image::DslContext; include Sugar::SequenceManipulation end
  class Convert::DslContext; include Sugar::SequenceManipulation end
end
