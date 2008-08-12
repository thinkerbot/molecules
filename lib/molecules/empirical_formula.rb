require 'constants/libraries/element'
require 'molecules/utils'
require 'strscan'

module Molecules
  Element = Constants::Libraries::Element
  
  # EmpiricalFormula represents the empirical formula (ex 'H(2)0') for
  # a molecule.  The formula is stored as an array of integers aligned
  # to the elements in EmpiricalFormula::ELEMENT_INDEX.  Hence:
  #
  #   EmpiricalFormula::ELEMENT_INDEX[0].name   # => "Hydrogen"
  #   EmpiricalFormula::ELEMENT_INDEX[1].name   # => "Oxygen"
  #
  #   water = EmpiricalFormula.new [2,1]
  #   water.to_s                                # => 'H(2)O'
  #   water.mass                                # => 18.0105646863
  #
  # EmpiricalFormula may be added, subtracted, and multiplied to
  # perform the expected operations:
  #
  #   alanine = EmpiricalFormula.new [5,1,3,1]
  #   (alanine - water).formula                 # => [3,0,3,1]
  #
  class EmpiricalFormula
    class << self

      # Parses a simple formula (formatted like those returned by 
      # EmpiricalFormula#to_s) into a EmpiricalFormula. Whitespace 
      # is allowed in the formula.
      # 
      #   EmpiricalFormula.parse("H(2)O").to_s           # => "H(2)O"
      #   EmpiricalFormula.parse("H (2) O").to_s         # => "H(2)O"
      #   EmpiricalFormula.parse("HO(-1)O(2)H").to_s     # => "H(2)O"
      #
      def parse_simple(chemical_formula)
        formula = chemical_formula.to_s.gsub(/\s+/, "")

        factor = nil
        composition = Hash.new(0)
        scanner = StringScanner.new(formula.reverse)
        while scanner.rest_size > 0
          case
          when scanner.scan_full(/\)(\d+-?)\(/, true, false)
            # found a factor
            factor = scanner[1].reverse.to_i
          when scanner.scan_full(/([a-z]?[A-Z])/, true, false)
            # found an element
            composition[scanner[1].reverse] += (factor == nil ? 1 : factor)

            # reset factor to nil
            factor = nil
          else
            raise ParseError.new("could not parse formula: #{chemical_formula}")
          end
        end
        factors = composition_to_factors(composition)
        block_given? ? yield(factors) : EmpiricalFormula.new(factors)
      end

      # Parses a generalized chemical formula into an EmpiricalFormula.
      # Formula sections can be nested with parenthesis, and multiple
      # sections can be added or subtracted within the formula.  
      #
      #   EmpiricalFormula.parse("H2O").to_s                   # => "H(2)O"
      #   EmpiricalFormula.parse("CH3(CH2)50CH3").to_s         # => "C(52)H(106)"
      #   EmpiricalFormula.parse("C2H3NO - H2O + NH3").to_s    # => "C(2)H(4)N(2)"
      #
      # Note that the format for EmpiricalFormula#to_s differs from the 
      # format that parse utilizes.
      #
      # To extend the functionality of parse, provide a block to receive
      # formula sections with unexpected punctuation and calculate an 
      # EmpiricalFormula therefrom.  If the block returns nil, 
      # then parse will raise an error.
      #
      #   block = lambda do |formula|
      #     case formula
      #     when /\[(.*)\]/
      #       factors = $1.split(/,/).collect {|i| i.strip.to_i }
      #       EmpiricalFormula.new(factors)
      #     else nil
      #     end
      #   end
      #
      #   EmpiricalFormula.parse("H2O + [2, 1]", &block).to_s   # => "H(4)O(2)"
      #   EmpiricalFormula.parse("H2O + :not_expected", &block) # !> ParseError
      #
      def parse(chemical_formula, &block)
        # Remove whitespace 
        formula = chemical_formula.to_s.gsub(/\s+/, "")

        # Split and handle multipart formulae
        case formula 
        when /\+/
          return formula.split(/\+/).inject(EmpiricalFormula.new) do |current, formula|
            current + parse(formula, &block)
          end
        when /-/
          splits = formula.split(/-/)
          first = parse(splits.shift, &block)
          return splits.inject(first) do |current, formula|
            current - parse(formula, &block)
          end
        when /[^A-Za-z0-9\\(\\)]/
          result = block_given? ? yield(formula) : nil
          return result unless result == nil
          
          raise ParseError.new("unexpected characters in formula: #{chemical_formula}")
        end

        # factor is the number following an element, as 6 and 12 in 'C6H12'
        # factor == -1 indicates that a number has not been read for the 
        # next element.  This state is used later to check for hanging 
        # factors, as in '2C6' or (8OH)
        factor = nil

        # multiplier is the latest cumulative factor for a parenthesis 
        # expression.  A new multiplier is pushed on the stack for every new
        # parenthesis set, and popped off when the set terminates.
        # ex: for CH3(C(H)2)7CH 
        #   At the period       Integer at the top of the stack equals
        #   CH3(C(H)2)7.CH      1
        #   CH3(C(H)2.)7CH      7
        #   CH3(C(H.)2)7CH      14
        #   CH3(C.(H)2)7CH      7
        #   CH3.(CH)2)7CH       1
        multiplier = []
        multiplier << 1

        # composition will store the formula composition as it is parsed
        composition = Hash.new(0)

        # Parse elements and factors out of the formula from right to left     
        scanner = StringScanner.new(formula.reverse)
        while scanner.rest_size > 0

          case
          when scanner.scan_full(/(\d+)/, true, false)
            # found a factor
            factor = scanner[1].reverse.to_i
          when scanner.scan_full(/([a-z]?[A-Z])/, true, false)
            # found an element

            # Adjust the factor by the multiplier.  If factor == nil 
            # then a factor has not been read for the element, as would
            # be seen in NaOH; use 1 in this case instead.
            factor = (factor.nil? ? 1 : factor) * multiplier.last

            # Add the current factor to composition, remembering to reverse the symbol
            composition[ scanner[1].reverse ] += factor

            # reset factor to nil
            factor = nil
          when scanner.scan_full(/\)/, true, false)
            # When a parenthesis ends, the current multiplier must be
            # adujusted by the current factor.  If factor == nil then a 
            # factor has not been read for the parenthesis, use 1 instead
            multiplier << (factor.nil? ? 1 : factor) * multiplier.last

            # reset factor to nil
            factor = nil
          when scanner.scan_full(/\(/, true, false)
            # When a parenthesis starts, the current multiplier is
            # popped off.  Check for hanging factors and that after 
            # popping a multiplier will remain.  If no multiplier will
            # remain, then the parenthesis must be mismatched
            raise ParseError.new("the formula contains a hanging factor: #{chemical_formula}") unless factor.nil?
            raise ParseError.new("the formula contains mismatched parenthesis: #{chemical_formula}") unless multiplier.length > 1

            multiplier.pop
          else
            raise ParseError.new("could not parse formula: #{chemical_formula}")
          end
        end

        # Check for hanging factors, that a multiplier remains, and that 
        # elements were found during parsing
        raise ParseError.new("the formula contains a hanging factor: #{chemical_formula}") unless factor.nil?
        raise ParseError.new("the formula contains mismatched parenthesis: #{chemical_formula}") unless multiplier.length == 1
        raise ParseError.new("no elements could be found in the formula: #{chemical_formula}") if composition.length == 0 && !formula.empty?

        EmpiricalFormula.new(composition_to_factors(composition))
      end

      # Parses the input formula into an EmpiricalFormula and 
      # calculates the mass therefrom.  By default the mass 
      # will be the monoisotopic mass of the formula.
      #
      # See EmpericalFormula#mass for more details.
      def mass(formula, &block) # :yields: element
        mass = parse(formula).mass(&block)
      end
      
      protected
      
      # Converts a hash of (symbol, factor) pairs into a factors array,
      # suitable for initializing an EmpiricalFormula.
      def composition_to_factors(composition)
        factors = []
        composition.each_pair do |symbol, factor|
          next if factor == 0

          element = symbol.kind_of?(Element) ? symbol : Element.index(:symbol)[symbol]
          if element == nil
            raise UnknownElementError.new("unknown element: #{symbol}")
          end

          factors[ELEMENT_INDEX.index(element)] = factor
        end
        factors
      end
    end
    
    class UnknownElementError < StandardError # :nodoc:
    end

    class ParseError < StandardError # :nodoc:
    end
    
    include Enumerable
    include Utils

    # An array defining the number of a given element in the formula.  The
    # order of elements in ELEMENT_INDEX correspond to order of forumula,
    # such that formula[1] indicates the number of ELEMENT_INDEX[1] elements
    # in self.
    attr_reader :formula

    def initialize(formula=[], normalize=true)
      @formula = formula

      if normalize
        # normalize by converting nils to zero and remove trailing zeros
        @formula.collect! {|factor| factor == nil ? 0 : factor}
        @formula.pop while @formula.last == 0
      end

      # ensure the formula cannot be changed
      @formula.freeze
    end

    # Returns a new EmpiricalFormula summing the formula of another and self.
    def +(another)
      EmpiricalFormula.new(add(self.formula.dup, another.formula), false)
    end

    # Returns a new EmpiricalFormula subtracting the formula of another from self.
    def -(another)
      EmpiricalFormula.new(add(self.formula.dup, another.formula, -1), false)
    end

    # Returns a new EmpiricalFormula multiplying the formula of self by factor.
    def *(factor)
      EmpiricalFormula.new(multiply(self.formula.dup, factor), false)
    end

    # True if another is an EmpiricalFormula and the formula of another equals the formula of self.
    def ==(another)
      another.kind_of?(EmpiricalFormula) && self.formula == another.formula
    end

    # Yields each element and the number of times that element occurs in self.
    def each # :yields: element, n
      formula.each_with_index do |n, index|
        next if n == 0
        yield(ELEMENT_INDEX[index], n)
      end
    end

    # Returns a formula string formatted like 'H(2)O' with the 
    # elements are sorted alphabetically by symbol.
    def to_s
      collect do |element, n|
        element.symbol + (n == 1 ? "" : "(#{n})")
      end.sort.join('')
    end
    
    # Calculates and returns the mass of self using the element
    # masses returned by the block. Returns the monoisotopic mass 
    # for the formula (ie the mass calculated from the most abundant 
    # natural isotope of each element) if no block is given.
    #
    #   water = EmpiricalFormula.new [2,1]
    #
    #   # monoisotopic mass calculation
    #   water.mass                                    # => 18.0105646863
    #   water.mass {|e| e.mass }                      # => 18.0105646863 
    #   
    #   # average mass calculation
    #   water.mass {|e| e.std_atomic_weight.value }   # => 18.01528
    #
    # ==== Notes
    # - The definition of monoisotopic mass conforms to
    #   that presented in 'Standard Definitions of Terms Relating 
    #   to Mass Spectrometry, Phil. Price, J. Am. Soc. Mass 
    #   Spectrom. (1991) 2 336-348' 
    #   (see {Unimod Mass Help}[http://www.unimod.org/masses.html])
    # - Masses are calculated such that mathematical operations 
    #   are performed on the return of the block.
    # 
    def mass(&block)
      if block_given? 
        mass = 0
        each {|e, n| mass = (yield(e) * n) + mass }
        mass
      else
        @monoisotopic_mass ||= mass {|e| e.mass}
      end
    end
    
    # An array of all element symbols ordered roughly by their occurence
    # in common biological molecules (ex water, carbohydrates, proteins).  
    ELEMENT_INDEX_ORDER = ['H', 'O', 'C', 'N', 'S', 'P', 'Fe', 'Ni', 'Se']
    
    # An array of all elements ordered as in ELEMENT_INDEX_ORDER
    ELEMENT_INDEX = Element.library.collect :element_index do |e|
      unless ELEMENT_INDEX_ORDER.include?(e.symbol)
        ELEMENT_INDEX_ORDER << e.symbol
      end
      
      [e, ELEMENT_INDEX_ORDER.index(e.symbol)]
    end
  end
end
