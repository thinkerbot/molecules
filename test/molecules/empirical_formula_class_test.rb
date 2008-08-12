require File.expand_path(File.join(File.dirname(__FILE__), '../molecules_test_helper.rb')) 
require 'molecules/empirical_formula'

class EmpiricalFormulaClassTest < Test::Unit::TestCase
  include Molecules
  
  #
  # parse_simple test
  #
  
  def test_parse_simple_documentation
    assert_equal "H(2)O", EmpiricalFormula.parse_simple("H(2)O").to_s
    assert_equal "H(2)O", EmpiricalFormula.parse_simple("H (2) O").to_s
    assert_equal "H(2)O", EmpiricalFormula.parse_simple("HO(-1)O(2)H").to_s
  end
  
  def test_parse_simple
    assert_equal([2,1], EmpiricalFormula.parse_simple("HO(-1)O(2)H").formula)
    assert_equal([2,1], EmpiricalFormula.parse_simple("H O (-1  )O( 2) H ").formula)
  end
  
  def test_parse_simple_fails_for_malformed_formulae
    [
      # numbers outside parenthesis
      "H2", 
      # empty parenthesis
      "H()",
      # mismatched parenthesis
      "H(",
      ")H",
      # anything complex
      "H + O"
    ].each do |formula|
      assert_raise(EmpiricalFormula::ParseError) { EmpiricalFormula.parse_simple(formula) }
    end
  end
  
  #
  # test class parse
  #
  
  def test_parse_documentation
    assert_equal "H(2)O", EmpiricalFormula.parse("H2O").to_s
    assert_equal "C(52)H(106)", EmpiricalFormula.parse("CH3(CH2)50CH3").to_s 
    assert_equal "C(2)H(4)N(2)", EmpiricalFormula.parse("C2H3NO - H2O + NH3").to_s 
    
    block = lambda do |formula|
      case formula
      when /\[(.*)\]/
        factors = $1.split(/,/).collect {|i| i.strip.to_i }
        EmpiricalFormula.new(factors)
      else nil
      end
    end
    
    assert_equal  "H(4)O(2)", EmpiricalFormula.parse("H2O + [2, 1]", &block).to_s
    assert_raise(EmpiricalFormula::ParseError) { EmpiricalFormula.parse("H2O + :not_expected", &block) }
  end
  
  def test_parse
    {
      nil => "",
      "" => "",
      "H" => "H", 
      "HO" => "HO", 
      "HFe" => "FeH", 
      "FeH" => "FeH", 
      "OH2" => "H(2)O",
      "H2O" => "H(2)O", 
      "C6H12O4" => "C(6)H(12)O(4)", 
      "Fe2OMg3" => "Fe(2)Mg(3)O", 
      "(H)2" => "H(2)", 
      "(OH)2" => "H(2)O(2)", 
      "(HFe)" => "FeH", 
      "(FeH)" => "FeH", 
      "(OH2)2" => "H(4)O(2)", 
      "(H2O)2" => "H(4)O(2)", 
      "(C6H12O4)2" => "C(12)H(24)O(8)",
      "(Fe2OMg3)2" => "Fe(4)Mg(6)O(2)",
      "C6H12O4(C6H12O4)2C6H12O4" => "C(24)H(48)O(16)", 
      "Fe2OMg3(Fe2OMg3(Fe2OMg3))Fe2OMg3" => "Fe(8)Mg(12)O(4)",
      "Fe2OMg3(Fe2OMg3)(Fe2OMg3)Fe2OMg3" => "Fe(8)Mg(12)O(4)",
      "Fe2OMg3(Fe2OMg3(Fe2OMg3)3((C)6H12O4)2)2C" => "C(25)Fe(18)H(48)Mg(27)O(25)",
      "  (H2O) 10 0   " => "H(200)O(100)",
      "CH3(CH2)7CH" => "C(9)H(18)", 
      "H3NCHCO2" => "C(2)H(4)NO(2)", 
      "(CH3)2CuLi" => "C(2)CuH(6)Li",
      
      # multipart
      "-H" => "H(-1)",
      "H2O-H" => "HO",
      "H2O - (OH)2+ H2O2-H2O" => ""
    }.each_pair do |formula, composition_str|
      m = EmpiricalFormula.parse(formula)
      assert_equal composition_str, m.to_s, formula
    end
  end
  
  def test_parse_fails_for_malformed_formulae
    [
      # mismatched parenthesis
      "H)2",
      "(H2", 
      "(O2(H2)",
      "(O)2H2)", 
      # hanging factors
      "2C", 
      #"(2)",
      "(2)2", 
      "(2C)", 
      "(2C)2",
      "C(2C)",
      # empty parenthesis
      "()",
      "()2"
    ].each do |formula|
      assert_raise(EmpiricalFormula::ParseError) { EmpiricalFormula.parse(formula) }
    end
  end
  
  #
  # class mass test
  #
  
  def break_test_class_mass_method
    water_mass = EmpiricalFormula::Element::H.mass * 2 + EmpiricalFormula::Element::O.mass
    assert_equal 18.010565, water_mass
    
    assert_equal 18.010565, EmpiricalFormula.mass("H2O")
    assert_equal 18.010565, EmpiricalFormula.mass("H + OH")
    assert_equal 18, EmpiricalFormula.mass("H2O", 0)
  end
  
  #
  # library molecules
  #
  
  def break_test_access_library_molecules
    water = EmpiricalFormula::H2O
    
    assert_equal water, EmpiricalFormula.lookup('h2o')
    assert_equal water, EmpiricalFormula.h2o
    assert_equal 18.010565, EmpiricalFormula.h2o.mass
  end

  # vs the VG Analytical Organic Mass Spectrometry reference, reference date unknown (prior to 2005)
  # the data from the data sheet was copied manually to doc/VG Analytical DataSheet.txt
  def test_molecule_mass_values_vs_vg_analytical
    str = %Q{
NH2 16.01872 16.0226
OH 17.00274 17.0073
OCH3 31.01839 31.0342
CH3CO 43.01839 43.0452}

    molecules = str.split(/\n/)
    molecules.each do |mol_str|
      next if mol_str.empty?
      
      name, monoisotopic, average = mol_str.split(/\s/)
      monoisotopic = monoisotopic.to_f
      average = average.to_f
      
      molecule = EmpiricalFormula.parse(name)
      assert_in_delta monoisotopic, molecule.mass, delta_mass, mol_str 
      # TODO -- check average mass
    end    
  end

  #
  # benchmark
  #
   
  def test_parse_speed
    benchmark_test(20) do |x|
      n = 10
       
      ["H20","H2(H2(H2))H2"].each do |formula|
        x.report("#{n}k #{formula}") do 
          (n*1000).times { EmpiricalFormula.parse(formula) }
        end
      end
    end
  end
   
  def test_parse_simple_speed
    benchmark_test(20) do |x|
      n = 10
       
      ["H(20)","H(2)H(2)H(2)H(2)"].each do |formula|
        x.report("#{n}k #{formula}") do 
          (n*1000).times { EmpiricalFormula.parse_simple(formula) }
        end
      end
    end
  end
end