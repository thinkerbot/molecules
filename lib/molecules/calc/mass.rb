require 'molecules/empirical_formula'

# patch for ruby units
class Unit < Numeric
  UNIT_DEFINITIONS['<AMU>'] = [%w{u AMU amu}, 1/6.0221415e26, :mass, %w{<kilogram>}]
  UNIT_DEFINITIONS['<dalton>'] = [%w{Da Dalton Daltons dalton daltons}, 1/6.0221415e26, :mass, %w{<kilogram>}]
end
Unit.setup

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
    
      config :type, :monoisotopic    # the mass type calculated
      config :precision, nil              # the precision of the mass
      config :units, "Da"                 # the mass unit reported

      def process(*formulae)
        formulae.collect do |formula|
          mass = EmpiricalFormula.mass(formula) do |element|
            case type
            when :monoisotopic then element.mass
            when :average then element.std_atomic_weight.value
            else raise "unknown mass type: #{type}"
            end
          end
          
          mass = Unit.new(mass, "Da").convert_to(units)
          unless precision == nil
            mass = Unit.new( Utils.round(mass.scalar, precision), units) 
          end
          
          log mass, formula
          mass
        end
      end
      
    end
  end
end