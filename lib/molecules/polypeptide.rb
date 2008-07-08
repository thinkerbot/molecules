require 'molecules/libraries/residue'

module Molecules

  # Represents a polypeptide as a sequence of residues.  For convenience,
  # polypeptides may contain whitespace in their sequences (thus allowing
  # direct use with parsed FASTA formatted peptides sequences).
  #
  # Currently polypeptide only handles sequences with common residues.
  class Polypeptide < EmpiricalFormula
    
    class << self
      # Normalizes the input sequence by removing whitespace and capitalizing.
      def normalize(sequence)
        sequence.gsub(/\s/, "").upcase
      end
    end
    
    class UnknownResidueError < StandardError # :nodoc:
    end
    
    # Alias for Molecules::Libraries::Residue
    Residue = Molecules::Libraries::Residue
    
    # The sequence of self (including whitespace)
    attr_reader :sequence
    
    # A hash of (Residue, Integer) pairs defining the number of a given residue in self.  
    attr_reader :residue_composition
    
    # The number of residues in self (may differ from sequence.length
    # if sequence contains whitespace).
    attr_reader :length
    
    # An array of tokens that may occur in a sequence, grouped
    # as patterns (ie one token for all whitespace characters, and 
    # one token for each residue).  Used to count the number of
    # each type of residue in a sequence.
    SEQUENCE_TOKENS = ["\s\t\r\n"] + Residue.common.collect {|r| r.letter}

    def initialize(sequence)
      @sequence = sequence

      @length = 0
      @residue_composition = {}
      @formula = Array.new(5, 0)
      
      # count up the number of whitespaces and residues in self
      tokens = Utils.count(sequence, SEQUENCE_TOKENS)
      whitespace = tokens.shift

      if whitespace == sequence.length
        # as per the Base specification, factors
        # should have no trailing zeros
        @formula.clear
        return
      end

      # add the residue masses and factors
      Residue.common.each do |residue|
        # benchmarks indicated that counting for each residue
        # is quicker than trying anything like:
        #
        #   sequence.each_byte {|b| bytes[b] += 1}
        #
        # This is particularly an issue for long sequences.  The
        # count operation could be optimized for isobaric residues
        n = tokens.shift
        next if n == 0

        @length += n
        @residue_composition[residue] = n
        Utils.add(@formula, residue.formula, n)
      end

      if @length + whitespace != sequence.length
        # raise an error if there are unaccounted characters
        raise UnknownResidueError, "unknown characters in sequence: #{sequence}"
      end
    end

    # Sequentially passes each residue in sequence to the block.
    def each_residue
      residues = Residue.residue_index
      sequence.each_byte do |byte|
        residue = residues[byte]
        yield(residue) if residue
      end
    end
    
  end
end