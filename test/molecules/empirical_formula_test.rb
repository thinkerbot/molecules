require File.expand_path(File.join(File.dirname(__FILE__), '../molecules_test_helper.rb')) 
require 'molecules/empirical_formula'

class EmpiricalFormulaTest < Test::Unit::TestCase
  include Molecules
  
  #
  # documentation test
  #
  
  def test_documentation
    assert_equal "Hydrogen", EmpiricalFormula::ELEMENT_INDEX[0].name
    assert_equal "Oxygen", EmpiricalFormula::ELEMENT_INDEX[1].name
  
    water = EmpiricalFormula.new [2,1]
    assert_equal 'H(2)O', water.to_s
    assert_equal 18.0105646863, water.mass 
    
    alanine = EmpiricalFormula.new [5,1,3,1]
    assert_equal [3,0,3,1], (alanine - water).formula
  end
  
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
  
  def test_mass_returns_monoisotopic_mass_if_no_block_is_given
    water = EmpiricalFormula.new [2,1]
    assert_equal 18.0105646863, water.mass
  end
  
  def test_mass_calculates_mass_using_block_result
    water = EmpiricalFormula.new [2,1]
    assert_equal 18.01528, water.mass {|e| e.std_atomic_weight.value }
  end
  
  class AltMass 
    attr_reader :value
    
    def initialize(value)
      @value = value
    end
    
    def +(another)
      another = another.value if another.kind_of?(AltMass)
      AltMass.new @value + another
    end
    
    def *(another)
      another = another.value if another.kind_of?(AltMass)
      AltMass.new @value * another
    end
  end
  
  def test_mass_calculation_operates_on_block_result
    water = EmpiricalFormula.new [2,1]
    result = water.mass {|e| AltMass.new e.mass }
    
    assert result.kind_of?(AltMass)
    assert_equal 18.0105646863, result.value
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
      
      x.report("#{n}k [1,2,3,4] mass") { (n*1000).times { a.mass {|e| e.mass } } }
      x.report("#{n}k [0,-1] mass") { (n*1000).times { b.mass {|e| e.mass } } }
    end
  end
end