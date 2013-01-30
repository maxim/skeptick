require 'skeptick/version'
require 'skeptick/convert'
require 'skeptick/image'
require 'skeptick/pipe'

module Skeptick
  def self.log(text)
    puts(text)
    # Rails.logger.debug(text)
  end

  def self.cd_path
    # Rails.root
  end

  def convert(*args, &blk)
    Skeptick::Convert.new(self, *args, &blk)
  end

  def image(*args, &blk)
    Skeptick::Image.new(self, *args, &blk)
  end

  def pipe(*args, &blk)
    Skeptick::Pipe.new(self, *args, &blk)
  end
end
