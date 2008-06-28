require 'molecules/emperical_formula'
require 'strscan'

module Molecules

  #--
  # add some standard formulae to the library
  # Note these MUST be added after the previous require statements
  # because of the dependencies:
  #   Formula => Element => Library
  #++
  module Molecule
    
    module_function

    def [](identifier)
      parse(identifier)
    end 

    def composition_to_factors(composition)
      factors = []
      composition.each_pair do |symbol, factor|
        next if factor == 0

        element = symbol.kind_of?(Element) ? symbol : Element[symbol]
        if element == nil
          raise UnknownElementError.new("unknown element: #{symbol}")
        end

        factors[element.index] = factor
      end
      factors
    end

    # Parses a simple formula (formatted like those returned by 
    # Composition#to_s) into a Composition. The format consists of the 
    # element symbol followed by parenthesis with the number of that 
    # element in the composition.  Whitespace is allowed in the formula.
    # 
    #   parse("H(2)O").to_s                   # => "H(2)O"
    #   parse("H (2) O").to_s                 # => "H(2)O"
    #   parse("HO(-1)O(2)H").to_s             # => "H(2)O"
    def parse_simple(chemical_formula)
      formula = chemical_formula.to_s.gsub(/\s+/, "")

      factor = nil
      composition = Hash.new(0)
      scanner = StringScanner.new(formula.reverse)
      while scanner.restsize > 0
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

    # Parses a generalized chemical formula into a Composition.
    # Formula sections can be nested with parenthesis, and multiple
    # sections can be added or subtracted within the formula.  Note
    # that the format for Composition#to_s differs from the format
    # that parse utilizes.
    #
    #   parse("H2O").to_s                   # => "H(2)O"
    #   parse("CH3(CH2)50CH3").to_s         # => "C(52)H(106)"
    #   parse("C2H3NO - H2O + NH3").to_s    # => "C(2)H(4)N(2)"
    #
    def parse(chemical_formula)
      # Remove whitespace 
      formula = chemical_formula.to_s.gsub(/\s+/, "")

      # Split and handle multipart formulae
      case formula 
      when /\+/
        return formula.split(/\+/).inject(EmpiricalFormula.new) do |current, formula|
          current + parse(formula)
        end
      when /-/
        splits = formula.split(/-/)
        first = parse(splits.shift)
        return splits.inject(first) do |current, formula|
          current - parse(formula)
        end
      when /[^A-Za-z0-9\\(\\)]/
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
      while scanner.restsize > 0

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

      factors = composition_to_factors(composition)
      block_given? ? yield(factors) : EmpiricalFormula.new(factors)
    end

    # Parses the input formula into an EmpiricalFormula (using
    # parse) then calculates the mass therefrom.  By default
    # the mass will be the monoisotopic mass of the formula;
    # see EmpericalFormula#mass for more details.
    def mass(formula, &block) # :yields: element
      mass = parse(formula).mass(&block)
    end

    class UnknownElementError < StandardError # :nodoc:
    end

    class ParseError < StandardError # :nodoc:
    end
  end

end