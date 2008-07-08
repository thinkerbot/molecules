module Molecules

  # A number of utility routines used by EmpiricalFormula and elsewhere.
  # These methods are used a great deal and are all prime candidates for 
  # optimization (for example using RubyInline).
  module Utils
    module_function
    
    # Rounds n to the specified precision (ie number of decimal places)
    def round(n, precision)
      factor = 10**precision.to_i
      (n * factor).round.to_f / factor
    end

    # Adds the elements of b to a at corresponding
    # indicies, multiplying by n.  The input arrays 
    # do not have to be the same length.  Returns a 
    # with trailing zeros removed.
    def add(a, b, n=1)
      a << 0 while a.length < b.length
      
      # oddly, this is faster than each_with_index
      i = 0
      b.each do |factor|
        a[i] += n * factor
        i += 1
      end
      
      a.pop while a[-1] == 0
      a
    end
    
    # Multiples the elements of array a by factor, returning a.
    # Clears a if factor == 0.
    def multiply(a, factor)
      factor == 0 ? a.clear : a.collect! {|i| i * factor}
    end
    
    # Collects the number of each of the patterns in str.  For example:
    #
    #   count("abcabca", ["a", "b", "c"])  # => [3, 2, 2]
    #   count("abcabca", ["a", "bc"])      # => [3, 4]
    #
    def count(str, patterns)
      patterns.collect {|pattern| str.count(pattern)}
    end
  end
  
end