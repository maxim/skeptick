module Skeptick
  class DslContext
    def write(path)
      append(:write, path)
    end
  end
end

