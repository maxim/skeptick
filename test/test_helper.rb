require 'bundler/setup'
require 'skeptick/core'
require 'minitest/autorun'

class Skeptick::TestCase < MiniTest::Unit::TestCase
  # Override this MiniTest method due to a diff issue with values like 0x123
  # https://github.com/seattlerb/minitest/issues/235
  def mu_pp_for_diff(obj)
    mu_pp(obj).gsub(/\\n/, "\n")
  end
end
