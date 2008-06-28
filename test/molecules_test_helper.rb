require 'rubygems'
require 'test/unit'
require 'benchmark'
require 'pp'

class Test::Unit::TestCase
  include Benchmark

  #
  # mass tests
  #
  
  def delta_mass
    10**-5
  end
  
  def delta_abundance
    10**-1
  end
  
  def benchmark_test(length=10, &block) 
    if ENV["benchmark"] =~ /true/i
      puts
      puts method_name
      bm(length, &block)
    else
      print 'b'
    end
  end
  
end
