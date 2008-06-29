require File.join(File.dirname(__FILE__), '../../tap_test_helper.rb') 
require 'molecules/calc/mass'

class Molecules::Calc::MassTest < Test::Unit::TestCase
  acts_as_tap_test 
  
  attr_reader :t
  
  def setup
    super
    @t = Molecules::Calc::Mass.new
  end
  
  def test_mass_calculation
    with_options(:quiet => true, :debug => true) do   
      t.enq("H2O")
      app.run
      
      assert_equal [[18.0105646863]], app.results(t)
    end
  end
  
  def test_mass_calculation_with_precision
    with_options(:quiet => true, :debug => true) do 
      t.precision = 2
      t.enq("H2O", "NH3 + H2O")
      app.run
      
      assert_equal [[18.01, 35.04]], app.results(t)
    end
  end
  
end