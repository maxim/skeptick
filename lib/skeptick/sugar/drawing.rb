module Skeptick
  module Sugar
    module Drawing
      def canvas(string, options = {})
        if options[:size]
          set '-size', options[:size]
        end

        set "canvas:#{string}"
      end

      def draw(*args)
        set '-draw', args.join(' ').shellescape
      end

      def write(text, options = {})
        if options[:left] && options[:top]
          opts = "#{options[:left]},#{options[:top]} "
        end

        draw "text #{opts}'#{text}'"
      end

      def font(name)
        set '-font', name.split(/\s/).map(&:capitalize).join('-')
      end
    end
  end

  class   Image::DslContext; include Sugar::Drawing end
  class Convert::DslContext; include Sugar::Drawing end
end
