require 'molecules/empirical_formula'
require 'molecules/libraries/polypeptide'

# patch for ruby units
class Unit < Numeric
  UNIT_DEFINITIONS['<AMU>'] = [%w{u AMU amu}, 1/6.0221415e26, :mass, %w{<kilogram>}]
  UNIT_DEFINITIONS['<dalton>'] = [%w{Da Dalton Daltons dalton daltons}, 1/6.0221415e26, :mass, %w{<kilogram>}]
end
Unit.setup

module Molecules

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
  class Calc < Tap::Task
  
    config :type, :monoisotopic              # the mass type calculated
    config :precision, nil                   # the precision of the mass
    config :units, "Da", &c.string           # the mass unit reported
    config :composition, false, &c.switch    # reports the composition, not the formula

    def initialize_unimod
      require 'active_unimod'
      ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => File.dirname(__FILE__) + '/../../../unimod'
    end
    
    def find_mod(code_name)
      initialize_unimod unless Object.const_defined?(:Modification)
      results = Modification.find :all, :conditions => ["code_name #{code_name.include?('%') ? 'LIKE' : '='} ?", code_name], :select => "code_name, composition"
      
      case results.length
      when 1 then EmpiricalFormula.parse_simple(results[0].composition)
      when 0 then raise "could not find modification: #{code_name}"
      else raise "multiple modifications found for: #{code_name} (#{results.collect {|m| m.code_name}.join(', ')})"
      end
    end
    
    WATER = EmpiricalFormula.parse "H2O"
    HYDROGEN = EmpiricalFormula.parse "H"
    HYDROXIDE = EmpiricalFormula.parse "OH"

    def process(*formulae)
      formulae.collect do |formula_str|
        formula = EmpiricalFormula.parse(formula_str) do |str|
          case str
          when /^(.*?):([A-Z]+):?(.*)$/
            peptide = Libraries::Polypeptide.new($2) + WATER
            peptide += find_mod($1) unless $1.to_s.empty? 
            peptide += find_mod($3) unless $3.to_s.empty?
            peptide
          else nil
          end
        end

        mass = formula.mass do |element|
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
        
        log mass, composition ? formula : formula_str

        mass
      end
    end
    
  end
end