module Skeptick
  class DslContext
    def swap(*args)
      if args.size != 0 && args.size != 2
        raise ArgumentError,
          "wrong number of arguments (#{args.size} for 0, 2)"
      end

      args.empty? ? set('+swap') : set(:swap, args.join(','))
    end
  end
end
