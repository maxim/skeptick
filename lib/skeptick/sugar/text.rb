module Skeptick
  class DslContext
    def text(string, options = {})
      if options[:left] && options[:top]
        opts = "#{options[:left]},#{options[:top]} "
      end

      set :draw, "text #{opts}'#{string}'"
    end
  end
end
