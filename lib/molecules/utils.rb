module Molecules
  #--
  # PRIME candidates for inline
  #++
  module Utils
    module_function

    def round(n, precision)
      factor = 10**precision.to_i
      (n * factor).round.to_f / factor
    end

    # Adds the elements of b to a at corresponding
    # indicies, multiplying by n.  a and b do not 
    # have to be the same length.
    def add(a, b, n=1)
      a << 0 while a.length < b.length
      i = 0
      b.each do |factor|
        a[i] += n * factor
        i += 1
      end
      a.pop while a[-1] == 0
      a
    end

    def multiply(a, x)
      x == 0 ? a.clear : a.collect! {|i| i * x}
    end

    def count(str, patterns)
      patterns.collect {|pattern| str.count(pattern)}
    end
  end
end