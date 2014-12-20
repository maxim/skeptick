module Skeptick
  class DslContext
    def delete(*args)
      obj = (args.size < 2 ? args.first : args)
      obj = obj.join(',') if obj.is_a?(Array)
      obj ? set(:delete, obj) : set('+delete')
    end
  end
end
