require File.join(File.dirname(__FILE__), '../molecules_test_helper.rb') 
require 'molecules/emperical_formula'

class EmpiricalFormulaTest < Test::Unit::TestCase
  include Molecules
  include Constants::Libraries

  #
  # initialize test
  #
  
  def test_initialize
    b = EmpiricalFormula.new([])
    assert_equal([], b.formula)

    water = EmpiricalFormula.new([2,1])
    assert_equal([2,1], water.formula)

    neg = EmpiricalFormula.new([2,-1])
    assert_equal([2,-1], neg.formula)

    zero = EmpiricalFormula.new([0,1,0])
    assert_equal([0,1], zero.formula)
  end

  #
  # each test
  #

  def test_each_returns_elements_and_formula_for_non_zero_formula
    formula = EmpiricalFormula.new([2,0,1])
    composition = {}
    formula.each {|element, factor| composition[element] = factor }
    
    assert_equal({Element::INDEX[0] => 2, Element::INDEX[2] => 1}, composition)
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
  # to_s test
  #
  
  def test_to_s
    c1 = EmpiricalFormula.new([2,1])
    assert_equal "H(2)O", c1.to_s
    
    c1 = EmpiricalFormula.new([-2,-1])
    assert_equal "H(-2)O(-1)", c1.to_s
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

end