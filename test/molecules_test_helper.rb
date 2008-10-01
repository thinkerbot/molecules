require 'rubygems'
require 'test/unit'
require 'benchmark'
require 'pp'

class Test::Unit::TestCase
  acts_as_subset_test

  #
  # mass tests
  #
  
  def delta_mass
    10**-5
  end
  
  def delta_abundance
    10**-1
  end
end
