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
  # Calculates the mass of a molecule or empirical formula.  The
  # options can be used to alter the output (precision, mass
  # calculation method etc.)  You may enter compound formulae, or
  # a list of formulae.  In addition, polypeptides can be specified 
  # using the one-letter residue codes:
  #
  #   % tap -- molecules/calc H2O
  #     I[17:09:00]   18.0105646863 Da H2O
  #
  #   % tap -- molecules/calc H2O -u kg
  #     I[13:35:59]    2.99072e-026 kg H2O
  #
  #   % tap -- molecules/calc 'C3H5NO + H2O' C50H73N15O11 -p 2
  #     I[17:08:21]           89.05 Da C3H5NO + H2O
  #     I[17:08:21]         1059.56 Da C50H73N15O11
  #
  #   % tap -- molecules/calc :RPPGFSPFR
  #     I[13:35:02]         1059.56 Da :RPPGFSPFR
  #
  # Furthermore, if a unimod path is specified in the configurations,
  # unimod modifcations may be specified by name as the polypeptide
  # termini.  Use '%' signs as in a SQL query to shorten the name:
  #
  #   % tap -- molecules/calc 'Acetyl:RPPGFSPFR:Hydroxyl%' --unimod-path <...>
  #     I[13:33:25]         1059.56 Da Acetyl:RPPGFSPFR:Hydroxyl%
  #
  # The unimod path must point to an sqlite3 ActiveUnimod database, and 
  # sqlite3-ruby must be installed for this feature to work.
  # 
  #   * ActiveUnimod[http://bioactive.rubyforge.org/]
  #   * sqlite3-ruby[http://rubyforge.org/projects/sqlite-ruby/]
  #  
  class Calc < Tap::Task
  
    config :type, :monoisotopic                             # the mass type calculated
    config :precision, nil, :short => 'p'                   # the precision of the mass
    config :units, "Da", :short => 'u', &c.string           # the mass unit reported
    config :composition, false, :short => 'c', &c.flag      # reports the composition, not the formula
    config :unimod_path, nil do |path|                      # the path to the unimod database
      case
      when path == nil then nil
      when File.exists?(path) then path
      else raise "path to unimod db does not exist: #{path}"
      end
    end
    
    # Formulates a query for a modification matching code_name 
    # for the unimod database.  If the code_name contains a '%'
    # then the query will use a LIKE syntax, otherwise the 
    # code_name will be searced for exactly.
    def mod_query(code_name)
      # should do a rails-like escape on code_name
      "SELECT code_name, composition FROM modifications WHERE code_name #{code_name.include?('%') ? 'LIKE' : '='} '#{code_name}'"
    end
    
    # Attempts to find and instantiate an EmpiricalFormula for
    # a unimod modification matching code_name.
    def find_mod(code_name)
      raise "no unimod_path was specified" if unimod_path == nil
      require 'sqlite3' unless Object.const_defined?(:SQLite3)
      
      results = []
      db = SQLite3::Database.new(unimod_path)
      db.execute(mod_query(code_name)) do |row|
        results << row
      end
      db.close
      
      case results.length
      when 1 then EmpiricalFormula.parse_simple(results[1])
      when 0 then raise "could not find modification: #{code_name}"
      else raise "multiple modifications found for: #{code_name} (#{results.collect {|result| result[0]}.join(', ')})"
      end
    end
    
    WATER = EmpiricalFormula.parse "H2O"
    HYDROGEN = EmpiricalFormula.parse "H"
    HYDROXIDE = EmpiricalFormula.parse "OH"
    
    # Returns an array of the calculated masses, in the correct unit.
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