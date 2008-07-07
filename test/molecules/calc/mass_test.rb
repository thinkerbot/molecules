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
      
      assert_equal [[Unit.new(18.0105646863, "Da")]], app.results(t)
    end
  end
  
  def test_mass_calculation_with_precision
    with_options(:quiet => true, :debug => true) do 
      t.precision = 2
      t.enq("H2O", "NH3 + H2O")
      app.run
      
      assert_equal [[Unit.new(18.01, "Da"), Unit.new(35.04, "Da")]], app.results(t)
    end
  end
  
  def test_mass_calculation_with_precision_and_unit_conversion
    with_options(:quiet => true, :debug => true) do 
      t.units = "yg"
      t.precision = 3
      t.enq("H2O")
      app.run
      
      assert_equal [[Unit.new(29.907, "yg")]], app.results(t)
    end
  end
end