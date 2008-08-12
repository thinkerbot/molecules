require File.expand_path( File.join(File.dirname(__FILE__), '../../molecules_test_helper.rb') )
require 'molecules/libraries/polypeptide'

class PolypeptideTest < Test::Unit::TestCase
  include Molecules::Libraries
  
  #
  # normalize test
  #

  def test_normalize_removes_whitespace_and_upcases_sequence
    assert_equal "ABC", Polypeptide.normalize("Ab\n\rC\t\s")
  end

  #
  # initialize test
  #

  def test_initialize
    p = Polypeptide.new("")
    assert_equal "", p.sequence
    assert_equal([],p.formula)
    assert_equal({},p.residue_composition)
    
    bradykinin = Polypeptide.new("RPPGFSPFR")
    assert_equal "RPPGFSPFR", bradykinin.sequence
    assert_equal [71, 10, 50, 15], bradykinin.formula
    assert_equal({
      Residue::R => 2, 
      Residue::P => 3, 
      Residue::G => 1, 
      Residue::F => 2, 
      Residue::S => 1},
    bradykinin.residue_composition)
  end

  def test_spaces_are_allowed_in_initialize
    p = Polypeptide.new("\s\t\r\n")
    assert_equal "\s\t\r\n", p.sequence
    assert_equal([],p.formula)
    assert_equal({},p.residue_composition)
    
    bradykinin = Polypeptide.new(" R PP\t\nGFSP\s  FR\r")
    assert_equal " R PP\t\nGFSP\s  FR\r", bradykinin.sequence
    assert_equal [71, 10, 50, 15], bradykinin.formula
    assert_equal({
      Residue::R => 2, 
      Residue::P => 3, 
      Residue::G => 1, 
      Residue::F => 2, 
      Residue::S => 1},
    bradykinin.residue_composition)
  end

  def test_initialize_raises_error_for_unknown_residues
    assert_nil Residue['Z']
    assert_raise(Polypeptide::UnknownResidueError) { Polypeptide.new("Z") }
  end

  def test_initialize_is_case_sensitive_for_residues
    assert_not_nil Residue['A']
    assert_raise(Polypeptide::UnknownResidueError) { Polypeptide.new("a") }
  end

  #
  # each_residue test
  #
  
  def test_each_residue_returns_each_residue_sequentially
    residues = []
    p = Polypeptide.new("\sRP PG\t F")
    p.each_residue {|r| residues << r}
    
    assert_equal [Residue::R, Residue::P, Residue::P, Residue::G, Residue::F], residues
  end
  
  #
  # benchmark
  #

  def test_initialize_speed
    benchmark_test(20) do |x|
      n = 10

      x.report("#{n}k RPPGFSPFR") do 
        (n*1000).times { Polypeptide.new("RPPGFSPFR") }
      end
      x.report("#{n}k RPPGFSPFR * 10") do 
        (n*1000).times { Polypeptide.new("RPPGFSPFR" * 10) }
      end
      x.report("#{n*10} RPPGFSPFR * 1000") do 
        (n*10).times { Polypeptide.new("RPPGFSPFR" * 1000) }
      end
    end
  end

  def test_each_residue_speed
    benchmark_test(20) do |x|
      p = Polypeptide.new("RPPGFSPFR" * 10) 
      
      x.report("1k RPPGFSPFR * 10") do 
        1000.times { p.each_residue {|r| r} }
      end
      x.report("1k each_byte:") do 
        1000.times { p.sequence.each_byte {|b| b} }
      end
    end
  end
  
  #def test_counting_vs_each_byte
  #  benchmark_test(20) do |x|
  #    sequence = "RPPGFSPFR" * 1000
  #    
  #    x.report("1k count") do 
  #      1000.times do 
  #        Utils.count(sequence, Polypeptide::SEQUENCE_TOKENS)
  #      end
  #    end
  #    
  #    x.report("1k each_byte") do 
  #      1000.times do
  #        array = Array.new(100, 0)
  #        sequence.each_byte {|b| array[b] += 1}
  #      end
  #    end
  #  end
  #end
end