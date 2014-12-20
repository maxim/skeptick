module Skeptick
  class DslContext
    def font(name)
      set '-font', name.split(/\s/).map(&:capitalize).join('-')
    end
  end
end
