require 'shellwords'
require 'skeptick/version'
require 'skeptick/wrapper/convert'
require 'skeptick/wrapper/compose'

# To prepare for open sourcing
#
# 1. Make log, cd_path, pipe format (perhaps other values) configurable
# 2. Write tests
# 3. Extract internal logic from DSL context (avoid _methods)
# 4. Document methods
# 5. Add Skeptick error type
# 6. Resolve/cleanup store_images/load_images mess

module Skeptick
  def self.log(text)
    puts(text)
    Rails.logger.debug(text)
  end

  def self.cd_path
    Rails.root
  end

  def convert(*args, &blk)
    Skeptick::Wrapper::Convert.new(self, *args, &blk)
  end

  def compose(*args, &blk)
    Skeptick::Wrapper::Compose.new(self, *args, &blk)
  end

  def pipe(*args, &blk)
    Skeptick::Pipe.new(self, *args, &blk)
  end
end
