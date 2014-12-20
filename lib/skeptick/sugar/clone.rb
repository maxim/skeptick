module Skeptick
  class DslContext
    def clone(*args)
      obj = (args.size < 2 ? args.first : args)
      obj  = obj.join(',') if obj.is_a?(Array)
      obj ? set(:clone, obj) : set('+clone')
    end
  end
end
