require File.join(File.dirname(__FILE__), '../tap_test_helper.rb') 
require 'molecules/calc'

class Molecules::CalcTest < Test::Unit::TestCase
  acts_as_tap_test 
  acts_as_shell_test(
    :cmd_pattern => '% tap',
    :cmd => 'tap',
    :env => {'TAP_GEMS' => 'tap-tasks'}
  )
  
  attr_reader :t
  
  def setup
    super
    @t = Molecules::Calc.new
  end
  
  #
  # documentation test
  #
  
  def test_documentation
    sh_test %q{
% tap run -- molecules/calc H2O --: dump
18.0106 Da
}
    sh_test %q{
% tap run -- molecules/calc "NH3 + H2O" --precision 2 --: dump
35.04 Da
}
    sh_test %q{
% tap run -- molecules/calc H2O --units yg --precision 2 --: dump
29.91 yg
}
    sh_test %q{
% tap run -- molecules/calc H2O --: inspect -m scalar
18.0105646863
}
  end
  
  #
  # process test
  #
  
  def test_mass_calculation
    assert_equal Unit.new(18.0105646863, "Da"), t.process("H2O")
  end
  
  def test_mass_calculation_with_precision
    t.precision = 2
    assert_equal Unit.new(18.01, "Da"), t.process("H2O")
  end
  
  def test_mass_calculation_with_precision_and_unit_conversion
    t.units = "yg"
    t.precision = 3
    assert_equal Unit.new(29.907, "yg"), t.process("H2O")
  end
end