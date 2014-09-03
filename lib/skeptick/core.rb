require 'skeptick/version'
require 'skeptick/convert'
require 'skeptick/image'
require 'skeptick/chain'
require 'skeptick/railtie' if defined?(Rails)

module Skeptick
  class << self
    attr_writer :debug_mode,
                :logger,
                :logger_method

    attr_accessor :cd_path, :timeout

    def log(message)
      @logger ||= ::STDOUT

      @logger_method ||=
        if    @logger.respond_to?(:debug); :debug
        elsif @logger.respond_to?(:puts);  :puts
        else  :write
        end

      @logger.public_send(@logger_method, message)
    end

    def debug_mode?
      @debug_mode
    end
  end

  def convert(*args, &blk)
    Skeptick::Convert.new(self, *args, &blk)
  end

  def image(*args, &blk)
    Skeptick::Image.new(self, *args, &blk)
  end

  def chain(*args, &blk)
    Skeptick::Chain.new(self, *args, &blk)
  end
end
