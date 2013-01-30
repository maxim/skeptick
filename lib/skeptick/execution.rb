require 'shellwords'
require 'open3'
require 'skeptick/error'

module Skeptick
  class Execution
    def initialize(command_obj)
      @command_obj = command_obj
    end

    def command
      @command_obj.to_s.shellsplit.shelljoin
    end

    def run
      Skeptick.log(@command_obj.parts.inspect)
      Skeptick.log("Skeptick: #{command}".gsub(/(.{1,80})(\s+|\Z)/, "\\1\n"))

      opts = {}
      opts[:chdir] = Skeptick.cd_path if Skeptick.cd_path

      out, err, status = Open3.capture3(command, opts)
      puts out
      err.each_line do |line|
        puts line unless line =~ /\A\d{4}/
      end

      if !status.success?
        raise ImageMagickError,
          "ImageMagick error\nCommand: #{command}\nSTDERR:\n#{err}"
      end
      out
    end
  end
end
