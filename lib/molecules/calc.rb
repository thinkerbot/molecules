require 'molecules/empirical_formula'
require 'molecules/libraries/polypeptide'

# patch for ruby units
class Unit < Numeric # :nodoc:
  UNIT_DEFINITIONS['<AMU>'] = [%w{u AMU amu}, 1/6.0221415e26, :mass, %w{<kilogram>}]
  UNIT_DEFINITIONS['<dalton>'] = [%w{Da Dalton Daltons dalton daltons}, 1/6.0221415e26, :mass, %w{<kilogram>}]
end
Unit.setup

module Molecules

  # :startdoc::manifest a mass calculator
  #
  # Calculates the mass of a molecule.  Compound formulae are allowed and you may
  # specify a list of formulae. The options can be used to alter the output (precision, 
  # mass calculation method etc.)
  #
  #   % tap -- molecules/calc H2O
  #     I[17:08:00]   18.0105646863 Da H2O
  #
  #   % tap -- molecules/calc H2O --units yg --precision 6
  #     I[17:08:21]       29.907243 yg H2O
  #
  #   % tap -- molecules/calc 'C3H5NO + H2O' C50H73N15O11 -p 2
  #     I[17:08:53]           89.05 Da C3H5NO + H2O
  #     I[17:08:53]         1059.56 Da C50H73N15O11
  #
  class Calc < Tap::Task
  
    config :type, :monoisotopic                             # the mass type calculated
    config :precision, nil, :short => 'p'                   # the precision of the mass
    config :units, "Da", :short => 'u', &c.string           # the mass unit reported
    config :composition, false, :short => 'c', &c.flag      # reports the composition, not the formula
    
    WATER = EmpiricalFormula.parse "H2O"
    HYDROGEN = EmpiricalFormula.parse "H"
    HYDROXIDE = EmpiricalFormula.parse "OH"
    
    def parse(formula)
      EmpiricalFormula.parse(formula)
    end
    
    # Returns an array of the calculated masses, in the correct unit.
    def process(*formulae)
      formulae.collect do |formula_str|
        mass = parse(formula_str).mass do |element|
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

        log "#{mass.scalar} #{mass.units}", composition ? formula : formula_str

        mass
      end
    end
    
  end
end