require File.join(File.dirname(__FILE__), '../molecules_test_helper.rb') 
require 'molecules/emperical_formula'

class EmpiricalFormulaTest < Test::Unit::TestCase
  include Molecules
  
  #
  # initialize test
  #
  
  def test_initialize
    e = EmpiricalFormula.new([])
    assert_equal([], e.formula)

    e = EmpiricalFormula.new([2,1])
    assert_equal([2,1], e.formula)
    
    e = EmpiricalFormula.new([2,-1])
    assert_equal([2,-1], e.formula)
  end
  
  def test_intialize_normalizes_formula_by_removing_trailing_zeros
    zero = EmpiricalFormula.new([0,1,0])
    assert_equal([0,1], zero.formula)
  end
  
  def test_intialize_normalizes_formula_by_converting_nils_to_zero
    zero = EmpiricalFormula.new([nil,1,nil,0])
    assert_equal([0,1], zero.formula)
  end
  
  def test_intialize_freezes_formula
    formula = [1,2,3]
    e = EmpiricalFormula.new(formula)
    
    assert e.formula.frozen?
    assert_equal formula.object_id, e.formula.object_id
  end

  #
  # + test
  #
  
  def test_PLUS
    c1 = EmpiricalFormula.new([1, 0, -1])
    c2 = EmpiricalFormula.new([1, 1, 1])
    
    c3 = c1 + c2
    assert_equal([2,1], c3.formula)
  end
  
  #
  # - test
  #
  
  def test_MINUS
    c1 = EmpiricalFormula.new([1, 0, -1])
    c2 = EmpiricalFormula.new([1, 1, 1])
    
    c3 = c1 - c2
    assert_equal([0, -1, -2], c3.formula)
  end

  #
  # * test
  #
  
  def test_MULTIPLY
    c1 = EmpiricalFormula.new([1, 0, -1])
    
    c3 = c1 * 2 * 3
    assert_equal([6, 0, -6], c3.formula)
  end
  
  #
  # == test
  #
  
  def test_EQUAL
    assert EmpiricalFormula.new([1]) == EmpiricalFormula.new([1])
    assert EmpiricalFormula.new([1]) == EmpiricalFormula.new([1, 0])
  end
  
  #
  # each test
  #

  def test_each_returns_elements_and_formula_for_non_zero_formula
    formula = EmpiricalFormula.new([2,0,1])
    composition = {}
    formula.each {|element, factor| composition[element] = factor }
    
    assert_equal({EmpiricalFormula::ELEMENT_INDEX[0] => 2, EmpiricalFormula::ELEMENT_INDEX[2] => 1}, composition)
  end
  
  #
  # to_s test
  #
  
  def test_to_s
    c1 = EmpiricalFormula.new([2,1])
    assert_equal "H(2)O", c1.to_s
    
    c1 = EmpiricalFormula.new([-2,-1])
    assert_equal "H(-2)O(-1)", c1.to_s
  end
  
  def test_to_s_symbols_are_sorted_alphabetically
    c = EmpiricalFormula.new([1, 1, 1])
    assert_equal "CHO", c.to_s
  end
  
  #
  # mass test
  #
  
  def test_mass_documentation
    water = EmpiricalFormula.new [2,1]
    
    assert_equal 18.0105646863, water.mass
    assert_equal 18.0105646863, water.mass {|e| e.mass }
    
    assert_equal 18.01528, water.mass {|e| e.std_atomic_weight.value }
  end
  
  #
  # benchmark
  #

  def test_operation_speed
    benchmark_test(20) do |x|
      n = 10
      a = EmpiricalFormula.new [1,2,3,4]
      b = EmpiricalFormula.new [0,-1]
       
      x.report("#{n}k +") { (n*1000).times { a + b } }
      x.report("#{n}k -") { (n*1000).times { a - b } }
      x.report("#{n}k *") { (n*1000).times { a * 3} }
    end
  end

  def test_mass_speed
    benchmark_test(20) do |x|
      n = 10
      a = EmpiricalFormula.new [1,2,3,4]
      b = EmpiricalFormula.new [0,-1]
      
      x.report("[1,2,3,4] mass") { (n*1000).times { a.mass {|e| e.mass } } }
      x.report("[0,-1] mass") { (n*1000).times { b.mass {|e| e.mass } } }
    end
  end
end