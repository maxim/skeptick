module Skeptick
  module Sugar
    module Debugging
      def save(path)
        apply('-write', path)
      end
    end
  end

  class   Image::DslContext; include Sugar::Debugging end
  class Convert::DslContext; include Sugar::Debugging end
end
