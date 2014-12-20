module Skeptick
  class DslContext
    def save(path)
      append(:write, path)
    end
  end
end

