require 'constants/library'
require 'molecules/molecule'

module Molecules
  module Libraries
    # A Library of amino acid residues.
    class Residue < Molecules::EmpiricalFormula
     
      attr_reader :letter, :abbr, :name, :side_chain, :type

      # The unrounded monoisotopic side chain mass 
      attr_reader :side_chain_mass

      # The uncharged, unrounded, monoisotopic residue mass 
      # (the backbone plus side chain mass, with no N- or C-terminus)
      attr_reader :residue_mass

      attr_reader :immonium_ion_mass

      def initialize(letter, abbr, name, side_chain_formula, classification=nil)
        @side_chain = Molecule.parse_simple(side_chain_formula)
        super( Utils.add(side_chain.formula.dup, BACKBONE.formula), false)

        @letter = letter
        @abbr = abbr
        @name = name
        @classification = classification

        @side_chain_mass = side_chain.mass
        @residue_mass = mass
        @immonium_ion_mass = @residue_mass + DELTA_IMMONIUM.mass
      end

      # True if the residue is a common residue
      def common?
        @classification == :common
      end

      def standard?
        @classification == :common || @classification == :standard
      end

      # True if the residue is a composite representing a set of isobaric residues
      def composite?
        @type == :composite
      end

      BACKBONE = Molecule.parse_simple('C(2)H(2)NO') 
      DELTA_IMMONIUM = Molecule.parse('-CO+H')

      A = Residue.new('A', "Ala", "Alanine", "CH(3)", :common)
      C = Residue.new('C', "Cys", "Cysteine", "CH(3)S", :common)
      D = Residue.new('D', "Asp", "Aspartic Acid", "C(2)H(3)O(2)", :common)
      E = Residue.new('E', "Glu", "Glutamic Acid", "C(3)H(5)O(2)", :common)
      F = Residue.new('F', "Phe", "Phenylalanine", "C(7)H(7)", :common)
      G = Residue.new('G', "Gly", "Glycine", "H", :common)
      H = Residue.new('H', "His", "Histidine", "C(4)H(5)N(2)", :common)
      I = Residue.new('I', "Ile", "Isoleucine", "C(4)H(9)", :common)
      K = Residue.new('K', "Lys", "Lysine", "C(4)H(10)N", :common)
      L = Residue.new('L', "Leu", "Leucine", "C(4)H(9)", :common)
      M = Residue.new('M', "Met", "Methionine", "C(3)H(7)S", :common)
      N = Residue.new('N', "Asn", "Asparagine", "C(2)H(4)NO", :common)
      #O = Residue.new('O', "Pyl", "Pyrrolysine", "C(9)H(17)NO", :uncommon)
      P = Residue.new('P', "Pro", "Proline", "C(3)H(5)", :common)
      Q = Residue.new('Q', "Gln", "Glutamine", "C(3)H(6)NO", :common)
      R = Residue.new('R', "Arg", "Arginine", "C(4)H(10)N(3)", :common)
      S = Residue.new('S', "Ser", "Serine", "CH(3)O", :common)
      T = Residue.new('T', "Thr", "Threonine", "C(2)H(5)O", :common)
      U = Residue.new('U', "Sec", "Selenocysteine", "CH(3)Se", :standard)
      V = Residue.new('V', "Val", "Valine", "C(3)H(7)", :common) 
      W = Residue.new('W', "Trp", "Tryptophan", "C(9)H(8)N", :common)
      Y = Residue.new('Y', "Tyr", "Tyrosine", "C(7)H(7)O", :common)

      O = Residue.new('O', "Orn", "Ornithine", "C(3)H(8)N", :uncommon)
      ABA = Residue.new(nil, 'Aba', 'Aminobutyric Acid', 'C(2)H(5)', :uncommon) 
      AECYS = Residue.new(nil, 'AECys', 'Aminoethylcysteine', 'C(3)H(8)NS', :uncommon) 
      AIB = Residue.new(nil, 'Aib', 'alpha-Aminoisobutyric Acid', 'C(2)H(5)', :uncommon) 
      CMCYS =Residue.new(nil, 'CMCys', 'Carboxymethylcysteine', 'C(3)H(5)O(2)S', :uncommon) 
      DHA = Residue.new(nil, 'Dha', 'Dehydroalanine', 'CH', :uncommon) 
      DHB = Residue.new(nil, 'Dhb', 'Dehydroamino-alpha-butyric Acid', 'C(2)H(3)', :uncommon) 
      HYL = Residue.new(nil, 'Hyl', 'Hydroxylysine', 'C(4)H(10)NO', :uncommon) 
      HYP = Residue.new(nil, 'Hyp', 'Hydroxyproline', 'C(3)H(5)O', :uncommon) 
      IVA = Residue.new(nil, 'Iva', 'Isovaline', 'C(3)H(7)', :uncommon) 
      NLEU = Residue.new(nil, 'nLeu', 'Norleucine', 'C(4)H(9)', :uncommon) 
      PIP = Residue.new(nil, 'Pip', '2-Piperidinecarboxylic Acid', 'C(4)H(7)', :uncommon) 
      PGLU = Residue.new(nil, 'pGlu', 'Pyroglutamic Acid', 'C(3)H(3)O', :uncommon) 
      SAR = Residue.new(nil, 'Sar', 'Sarcosine', 'CH(3)', :uncommon) 
      
      include Constants::Library
      
      # Reset the library items to only include the Residues in the lookup.
      library.index_by_attribute :letter
      library.index_by_attribute :abbr
      library.index_by_attribute :name
      
      library.collect(:common) do |residue|
        residue.common? ? residue : nil
      end

      library.collect(:residue_index) do |residue|
        next unless residue.common? 
        [residue, residue.letter[0]]
      end

      library.collect(:residue_mass_index) do |residue|
        next unless residue.common? 
        [residue.residue_mass, residue.letter[0]]
      end

      class << self
        # The 20 common amino acids.
        def common
          collection(:common)
        end

        # An array of the residues indexed by the byte
        # corresponding to the residue letter.
        def residue_index
          collection(:residue_index)
        end

        # An array of the residue masses indexed by the byte
        # corresponding to the residue letter.
        def residue_mass_index
          collection(:residue_mass_index)
        end
      end  
    end
  end
end