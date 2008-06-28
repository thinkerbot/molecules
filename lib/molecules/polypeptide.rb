require 'molecules/libraries/residue'

module Molecules
  class Polypeptide < EmpiricalFormula
    Residue = Molecules::Libraries::Residue
    
    attr_reader :sequence, :residue_composition, :length

    SEQUENCE_TOKENS = ["\s\t\r\n"] + Residue.common.collect {|r| r.letter}

    def initialize(sequence)
      @sequence = sequence

      @length = 0
      @residue_composition = {}
      @formula = Array.new(5, 0)

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
        #   sequence.each_byte {|b| bytes[b] += 1}
        # this could be further optimized for isobaric residues
        n = tokens.shift
        next if n == 0

        @length += n
        @residue_composition[residue] = n
        Utils.add(@formula, residue.formula, n)
      end

      if @length + whitespace != sequence.length
        # raise an error if there are unaccounted characters
        raise "unknown characters in sequence: #{sequence}"
      end
    end

    # Sequentially passes each residue in the sequence to the block.
    def each_residue
      residues = Residue.residue_index
      sequence.each_byte do |byte|
        residue = residues[byte]
        yield(residue) if residue
      end
    end
    
    class << self
      # Normalizes the input sequence by removing whitespace and capitalizing.
      def normalize(sequence)
        sequence.gsub(/\s/, "").upcase
      end
    
      # def ms(sequence, options={})
      #   options = {
      #     :n => 1#,
      #     #:digester => trypsin,
      #     #:fragmentation => 
      #   }.merge(options)
      # end
    end
  end
end