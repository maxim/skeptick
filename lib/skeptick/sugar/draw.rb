module Skeptick
  class DslContext
    def draw(*args)
      set :draw, args.join(' ')
    end
  end
end
