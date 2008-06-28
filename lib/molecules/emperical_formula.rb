require 'constants/libraries/element'
require 'molecules/utils'

module Molecules
  Element = Constants::Libraries::Element
  
  class EmpiricalFormula
    include Enumerable
    
    # An array defining the number of a given element in the formula.  The
    # order of elements in Element.index correspond to order of forumula,
    # such that formula[1] indicates the number of Element.index[1] elements
    # in self.
    attr_accessor :formula

    def initialize(formula=[], normalize=true)
      @formula = formula

      if normalize
        # normalize by converting nils to zero and remove trailing zeros
        @formula.collect! {|factor| factor == nil ? 0 : factor}
        @formula.pop while @formula.last == 0
      end

      # ensure the formula aren't going to get changed
      @formula.freeze
    end

    # Returns a new EmpiricalFormula summing the formula of another and self.
    def +(another)
      EmpiricalFormula.new Utils.add(self.formula.dup, another.formula), false
    end

    # Returns a new EmpiricalFormula subtracting the formula of another from self.
    def -(another)
      EmpiricalFormula.new Utils.add(self.formula.dup, another.formula, -1), false
    end

    # Returns a new EmpiricalFormula multiplying the formula of self by factor.
    def *(factor)
      EmpiricalFormula.new Utils.multiply(self.formula.dup, factor), false
    end

    # True if another is an EmpiricalFormula and the formula of another equals the formula of self.
    def ==(another)
      another.kind_of?(EmpiricalFormula) && self.formula == another.formula
    end

    def mass(&block)
      if block_given? 
        mass = 0
        each {|e, n| mass += n * yield(e)}
        mass
      else
        @monoisotopic_mass ||= mass {|e| e.mass}
      end
    end

    # Yields each element and the number of times that element occurs in self.
    def each # :yields: element, n
      formula.each_with_index do |n, index|
        next if n == 0
        yield(Element::INDEX[index], n)
      end
    end

    # Returns a formula string formatted like: 'H(2)O'
    def to_s
      collect do |element, n|
        element.symbol + (n == 1 ? "" : "(#{n})")
      end.sort.join('')
    end

  end
end
