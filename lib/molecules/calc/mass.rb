require 'molecules/empirical_formula'

module Molecules
  module Calc
    
    # :manifest: a mass calculator
    # Calculates the mass of a molecule or empirical formula.  The
    # options can be used to alter the output (precision, mass
    # calculation method etc.)
    #
    # You may enter compound formulae, as well as a list of formulae.
    #
    #   % tap -- molecules/calc/mass H2O
    #     I[17:09:00]      18.0105646863 H2O
    #
    #   % tap -- molecules/calc/mass 'C3H5NO + H2O' C50H73N15O11 --precision=2
    #     I[17:08:21]              89.05 C3H5NO + H2O
    #     I[17:08:21]            1059.56 C50H73N15O11
    #
    class Mass < Tap::Task
    
      config :type, :monoisotopic
      config :precision, nil
      #config :units, :Da

      def process(*formulae)
        formulae.collect do |formula|
          mass = EmpiricalFormula.mass(formula) do |element|
            case type
            when :monoisotopic then element.mass
            when :average then element.std_atomic_weight.value
            end
          end
          
          mass = (precision == nil ? mass : Utils.round(mass, precision))
          
          log mass, formula
          mass
        end
      end
      
    end
  end
end