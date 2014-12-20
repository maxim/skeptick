module Skeptick
  class DslContext
    def canvas(string, options = {})
      set(:size, options[:size]) if options[:size]
      set "canvas:#{string}"
    end
  end
end
