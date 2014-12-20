module Skeptick
  class DslContext
    def format(*args)
      set '-format', args.join(' ')
    end
  end
end
