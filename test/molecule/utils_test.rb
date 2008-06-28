require File.join(File.dirname(__FILE__), '../molecules_test_helper.rb') 
require 'molecules/utils'

class UtilsTest < Test::Unit::TestCase
  include Molecules::Utils
  
  #
  # round test
  #
  
  def test_round
    assert_equal 0, round(0.20, 0)
    assert_equal 0.2, round(0.20, 1)
    assert_equal 0.2, round(0.20, 2)
    assert_equal 0.2, round(0.20, 3)
     
    assert_equal 0.2, round(0.18, 1)
    assert_equal 0.2, round(0.15, 1)
    assert_equal 0.1, round(0.13, 1)
    assert_equal 0.13, round(0.13, 3)
    
    assert_equal 10, round(13, -1)
    assert_equal 0, round(13, -2)
  end
  
  
  #
  # benchmark tests
  #
  
  def test_round_speed
    benchmark_test(24) do |x|
      n = 100
      x.report("#{n}k 1234.5678.round") do 
        (n*10**3).times { 1234.5678.round }
      end
      
      x.report("#{n}k 1234.5678 (2)") do 
        (n*10**3).times { round(1234.5678, 2) }
      end
      
      x.report("#{n}k 1234.5678 (5)") do 
        (n*10**3).times { round(1234.5678, 5) }
      end
    end
  end
end