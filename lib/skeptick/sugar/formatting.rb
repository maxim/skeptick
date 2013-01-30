module Skeptick
  module Sugar
    module Formatting
      def format(*args)
        set '-format', args.join(' ').shellescape
      end
    end
  end

  class   Image::DslContext; include Sugar::Formatting end
  class Convert::DslContext; include Sugar::Formatting end
end
