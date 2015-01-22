require 'skeptick/dsl_context'
require 'skeptick/command'

module Skeptick
  class Convert
    attr_reader :context, :prepends, :subjects, :appends

    BINARY_PATH = 'convert'.freeze
    DEFAULT_OUTPUT = 'miff:-'.freeze

    def initialize(context, *args, &blk)
      @context = context
      opts = args.last.is_a?(Hash) ? args.pop : {}

      @objects = [
        @beginning = BINARY_PATH.dup,
        @prepends  = setup_prepends,
        @subjects  = setup_subjects,
        @appends   = setup_appends,
        @ending    = opts.fetch(:to){ DEFAULT_OUTPUT }.dup
      ]

      args.each do |arg|
        subjects << if arg.is_a?(Convert)
          arg
        else
          Convert.new(@context).tap{ |c| c.subjects << arg }
        end
      end

      DslContext.new(self).instance_eval(&blk) if block_given?
    end

    def run; command.run end
    def to_s; shellwords.join(' ') end
    def inspect; "#{self.class}(\"#{to_s}\")" end
    def shellwords; tokens.map { |obj| token_to_str(obj) } end
    def command; Command.new(shellwords) end

    protected

    def nest!
      add_parenth = (@subjects.size > 1) ||
        (@subjects.size < 2 && (!appends.empty? || !prepends.empty?))

      if add_parenth
        @beginning.replace('(')
        @ending.replace(')')
      else
        @beginning.clear
        @ending.clear
      end
    end

    def tokens
      @objects.flatten.reject{ |obj| empty_string?(obj) }.map { |obj|
        if obj.is_a?(Convert)
          obj.nest!
          obj.tokens
        else
          obj
        end
      }.flatten.tap do |array|
        if array[1] == '(' && array[-2] == ')'
          array.delete_at(1)
          array.delete_at(-2)
        end
      end
    end

    private

    def setup_prepends; [] end
    def setup_subjects; [] end
    def setup_appends;  [] end

    def empty_string?(obj)
      obj.is_a?(String) && obj.empty?
    end

    def token_to_str(obj)
      case obj
      when Symbol
        "-#{obj}"
      when Range
        "#{obj.min}-#{obj.max}"
      else
        obj.to_s
      end
    end
  end
end
