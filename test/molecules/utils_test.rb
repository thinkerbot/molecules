require File.expand_path(File.join(File.dirname(__FILE__), '../molecules_test_helper.rb')) 
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
  # add
  #
  
  def test_add_adds_the_elements_of_b_to_a_at_corresponding_indicies
    assert_equal [2,3,4], add([1,3,-1], [1,0,5])
  end
  
  def test_add_multiplies_the_elements_of_b_by_factor
    assert_equal [3,3,9], add([1,3,-1], [1,0,5], 2)
    assert_equal [1,3,-1], add([1,3,-1], [1,0,5], 0)
  end
  
  def test_add_removes_trailing_zeros_from_a
    assert_equal [], add([1,1,1], [-1,-1,-1])
  end
  
  def test_add_returns_a
    a = [1,2,4]
    assert_equal a.object_id, add(a, [1,0,4]).object_id
  end
  
  def test_add_does_not_require_a_and_b_to_be_the_same_length
    a = [1,2]
    b = [1]
    
    assert_equal [2,2], add(a, b)
    
    a = [1,2]
    b = [1]
    
    assert_equal [2,2], add(b, a)
  end
  
  #
  # multiply test
  #
  
  def test_multiply_multiplies_elements_of_a_by_factor
    assert_equal [2,4,-6], multiply([1,2,-3], 2)
    assert_equal [-2,-4,6], multiply([1,2,-3], -2)
  end
  
  def test_multiply_clears_a_for_zero_factor
    assert_equal [], multiply([1,2,-3], 0)
  end
  
  def test_mulitply_returns_a
    a = [1,2,4]
    assert_equal a.object_id, multiply(a, 2).object_id
    assert_equal a.object_id, multiply(a, 0).object_id
  end
  
  #
  # count test
  #
  
  def test_count_documenation
    assert_equal [3, 2, 2] , count("abcabca", ["a", "b", "c"])
    assert_equal [3, 4], count("abcabca", ["a", "bc"])
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
  
  def test_add_speed
    benchmark_test(30) do |x|
      n = 100
      x.report("#{n}k add([1,3,-1], [1,0,5])") do 
        (n*10**3).times { add([1,3,-1], [1,0,5]) }
      end
      
      x.report("#{n}k add([1,3,-1], [1])") do 
        (n*10**3).times { add([1,3,-1], [1]) }
      end
      
      x.report("#{n}k add([1], [1,3,-1])") do 
        (n*10**3).times { add([1], [1,3,-1]) }
      end
      
      x.report("#{n}k add([1,1,1], [-1,-1,-1])") do 
        (n*10**3).times { add([1,1,1], [-1,-1,-1]) }
      end
      
      x.report("#{n}k add([1,3,-1], [1,0,5], 2)") do 
        (n*10**3).times { add([1,3,-1], [1,0,5], 2) }
      end
    end
  end
    
  def test_multiply_speed
    benchmark_test(30) do |x|
      n = 100
      x.report("#{n}k multiply([1,3,-1], 2)") do 
        (n*10**3).times { multiply([1,3,-1], 2) }
      end
      
      x.report("#{n}k multiply([1,3,-1], 0)") do 
        (n*10**3).times { multiply([1,3,-1], 0) }
      end
    end
  end
  
end