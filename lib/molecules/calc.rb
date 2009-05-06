require 'tap/task'
require 'molecules/empirical_formula'
require 'molecules/libraries/polypeptide'

# patch for ruby units
class Unit < Numeric # :nodoc:
  UNIT_DEFINITIONS['<AMU>'] = [%w{u AMU amu}, 1/6.0221415e26, :mass, %w{<kilogram>}]
  UNIT_DEFINITIONS['<dalton>'] = [%w{Da Dalton Daltons dalton daltons}, 1/6.0221415e26, :mass, %w{<kilogram>}]
end
Unit.setup

module Molecules

  # :startdoc::task a mass calculator
  #
  # Calculates the mass of a molecule or formula. The options can be used to
  # alter the output (precision,  mass calculation method etc.)
  #
  #   % tap run -- molecules/calc H2O --: dump
  #   18.0106 Da
  #   
  #   % tap run -- molecules/calc "NH3 + H2O" --precision 2 --: dump
  #   35.04 Da
  #
  # Units can carry prefixes (ex 'mm', 'kg').  See {Ruby Units}[http://ruby-units.rubyforge.org/ruby-units/]
  # for more information.
  #
  #   % tap run -- molecules/calc H2O --units yg --precision 2 --: dump
  #   29.91 yg
  #
  # Note that Calc returns instances of Unit, which by default prints itself
  # with a precison of 4.  To view the full-precision value, inspect the scalar
  # value of the result.
  #
  #   % tap run -- molecules/calc H2O --: inspect -m scalar
  #   18.0105646863
  #
  class Calc < Tap::Task
  
    config :type, :monoisotopic                             # the mass type calculated
    config :precision, nil, :short => 'p'                   # the precision of the mass
    config :units, "Da", :short => 'u', &c.string           # the mass unit reported
    config :composition, false, :short => 'c', &c.flag      # reports the composition, not the formula
    
    # Parses the formula string into an EmpiricalFormula.
    # Can be used as a hook for more complicated formulae
    # in subclases.
    def parse(formula)
      EmpiricalFormula.parse(formula)
    end
    
    # Returns an array of the calculated masses, in the correct unit.
    def process(formula)
      mass = parse(formula).mass do |element|
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

      mass
    end
    
  end
end