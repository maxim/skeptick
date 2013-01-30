module Skeptick
  module Sugar
    module Composition
      module Helper
        def compose(blending, *args, &blk)
          convert(*args, &blk).tap do |c|
            c.append :compose, blending.to_s
            c.append :composite
          end
        end
      end

      module Operators
        def +(other)
          compose(:over, self, other)
        end

        def -(other)
          compose(:dstout, self, other)
        end

        def *(other)
          compose(:multiply, self, other)
        end

        def /(other)
          compose(:divide, self, other)
        end

        def &(other)
          compose(:dstin, self, other) { apply '-alpha Set' }
        end

        def |(other)
          compose(:dstover, self, other)
        end
      end
    end
  end

  include Sugar::Composition::Helper

  class   Image::DslContext; include Sugar::Composition::Helper end
  class Convert::DslContext; include Sugar::Composition::Helper end

  class   Image; include Sugar::Composition::Operators end
  class Convert; include Sugar::Composition::Operators end
end
