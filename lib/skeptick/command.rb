require 'shellwords'
require 'posix/spawn'
require 'skeptick/error'

module Skeptick
  class Command
    attr_reader :shellwords

    def initialize(shellwords)
      @shellwords = shellwords
    end

    def to_s
      shellwords.join(' ')
    end

    def run(spawn_options = {})
      opts = {}
      opts[:chdir]   = Skeptick.cd_path.to_s if Skeptick.cd_path
      opts[:timeout] = Skeptick.timeout if Skeptick.timeout
      opts.merge(spawn_options)

      if Skeptick.debug_mode?
        Skeptick.log("Skeptick Command: #{to_s}")
      end

      im_process = POSIX::Spawn::Child.new(*shellwords, opts)

      if !im_process.success?
        raise ImageMagickError,
          "ImageMagick error\nCommand: #{to_s}\nSTDERR:\n#{im_process.err}"
      end

      im_process.status
    end
  end
end
