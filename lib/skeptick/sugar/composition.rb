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

  # Include compose into external context
  include Sugar::Composition::Helper

  # Include compose into Image's and Convert's DSL context
  class   Image::DslContext; include Sugar::Composition::Helper end
  class Convert::DslContext; include Sugar::Composition::Helper end

  # Include compose into Image and Convert objects
  class   Image; include Sugar::Composition::Helper end
  class Convert; include Sugar::Composition::Helper end

  # Include operators into Image and Convert objects
  class   Image; include Sugar::Composition::Operators end
  class Convert; include Sugar::Composition::Operators end
end
