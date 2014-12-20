require 'skeptick/sugar/compose'

module Skeptick
  module TornPaperImage
    def torn_paper_image(*args, &blk)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      spread    = opts[:spread]    || 1
      blur      = opts[:blur]      || '0x.7'
      threshold = opts[:threshold] || 50

      compose(:copy_opacity, *args) do
        convert(&blk) if block_given?
        convert do
          set '+clone'
          set '-virtual-pixel', 'transparent'
          set :spread, spread
          set :channel, 'A'
          set :blur, blur
          set :threshold, "#{threshold}%"
        end

        set :blur, blur
      end
    end
  end

  class DslContext
    include TornPaperImage
  end

  include TornPaperImage
end
