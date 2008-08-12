require File.expand_path( File.join(File.dirname(__FILE__), 'molecules_test_helper.rb') )
require 'molecules'

class MoleculesTest < Test::Unit::TestCase
 
  include Molecules::Libraries
  
  def test_readme_documentation
    r = Residue::A
    assert_equal "Alanine", r.name
    assert_equal "Ala", r.abbr
    assert_equal "A", r.letter
    assert_equal "CH(3)", r.side_chain.to_s
    assert_in_delta 71.03711, r.mass, 0.00001
    assert_in_delta 44.05002, r.immonium_ion_mass, 0.00001
  
    p = Polypeptide.new("RPPGFSPFR")
    assert_equal "C(50)H(71)N(15)O(10)", p.to_s
    assert_in_delta 1041.5508, p.mass , 0.0001
  
    caffeine = Molecules::EmpiricalFormula.parse("C8H10N4O2")
    coffee = Molecules::EmpiricalFormula.parse("C8H10N4O2 + H2O")
  end
end