require 'constants/libraries/element'
require 'molecules/utils'

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
    include Enumerable
    include Utils
    
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
    # that presented in 'Standard Definitions of Terms Relating 
    # to Mass Spectrometry, Phil. Price, J. Am. Soc. Mass 
    # Spectrom. (1991) 2 336-348' 
    # (see {Unimod Mass Help}[http://www.unimod.org/masses.html])
    # - Masses are calculated such that mathematical operations 
    # are performed on the return of the block.
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

  end
end
