module Skeptick
  module Helper
    def extract_options!(array)
      array.last.is_a?(Hash) ? array.pop : {}
    end
  end
end
