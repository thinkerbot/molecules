require File.join(File.dirname(__FILE__), '../../molecules_test_helper.rb') 
require 'molecules/libraries/residue'

class ResidueTest < Test::Unit::TestCase
  include Molecules::Libraries

  #
  # documentation test
  #
  
  def test_documentation
    r = Residue::A
    assert_equal "Alanine", r.name
    assert_equal "Ala", r.abbr
    assert_equal "A", r.letter
    assert_equal "CH(3)", r.side_chain.to_s
  end
  
  def test_common_returns_array_of_common_residues
    assert_equal 20, Residue.common.length
    assert_equal ['A', 'R', 'N', 'D', 'C', 'E', 'Q', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V'].sort, Residue.common.collect {|e| e.letter}.sort
  end
  
  def test_class_lookup
    a = Residue::A
  
    assert_equal a, Residue['A']
    assert_equal a, Residue['Ala']
    assert_equal a, Residue['Alanine']

    assert_nil Residue['X']
    assert_nil Residue['BACKBONE']
    assert_raise(NoMethodError) { Residue.backbone }
  end
  
  def test_residue_mass_equals_mass_with_parameters
    ala = Residue::A
    assert_equal ala.mass, ala.residue_mass
  end
  
  def test_mass_values
    {
      'A' => 71.03711,
      'R' => 156.10111,
      'N' => 114.04293,
      'D' => 115.02694,
      'C' => 103.00919,
      'E' => 129.04259,
      'Q' => 128.05858,
      'G' => 57.02146,
      'H' => 137.05891,
      'I' => 113.08406,
      'L' => 113.08406,
      'K' => 128.09496,
      'M' => 131.04049,
      'O' => 211.14465,
      'F' => 147.06841,
      'P' => 97.05276,
      'S' => 87.03203,
      'T' => 101.04768,
      'U' => 150.95363,
      'W' => 186.07931,
      'Y' => 163.06333,
      'V' => 99.06841
    }.each_pair do |residue, expected|
      assert_in_delta expected, Residue[residue].mass, delta_mass
    end
  end
    
  def test_immonium_ion_mass
    {
      'A' => 44.05002,
      'R' => 129.11402,
      'N' => 87.05584,
      'D' => 88.03985,
      'C' => 76.02210,
      'E' => 102.05550,
      'Q' => 101.07149,
      'G' => 30.03437,
      'H' => 110.07182,
      'I' => 86.09697,
      'L' => 86.09697,
      'K' => 101.10787,
      'M' => 104.05340,
      'O' => 184.15756,
      'F' => 120.08132,
      'P' => 70.06567,
      'S' => 60.04494,
      'T' => 74.06059,
      'U' => 123.96654,
      'W' => 159.09222,
      'Y' => 136.07624,
      'V' => 72.08132
    }.each_pair do |residue, expected|
      assert_in_delta expected, Residue[residue].immonium_ion_mass, delta_mass
    end
  end

  # vs the Proteome Commons Residue Reference, 2008-01-11
  # http://www.proteomecommons.org/archive/1129086318745/docs/residue-reference.html
  def test_mass_values_vs_proteome_commons
    str = %Q{
Alanine A 71.0371137878
Arginine  R 156.1011110281
Asparagine  N 114.0429274472
Aspartic Acid D 115.02694303199999
Cysteine  C 103.00918447779999
Glutamic Acid E 129.0425930962
Glutamine Q 128.05857751140002
Glycine G 57.0214637236
Histidine H 137.0589118624
Isoleucine  I 113.0840639804
Leucine L 113.0840639804
Lysine  K 128.0949630177
Methionine  M 131.0404846062
Phenylalanine F 147.0684139162
Proline P 97.052763852
Serine  S 87.0320284099
Threonine T 101.0476784741
Tryptophan  W 186.0793129535
Tyrosine  Y 163.0633285383
Valine  V 99.0684139162}

    residues = str.split(/\n/)
    residues.each do |residue_str|
      next if residue_str.empty?
      
      residue_str =~ /(.*)\s(\w)\s(\d+\.\d+)/
      name = $1.strip
      letter = $2
      mass = $3.to_f

      residue = Residue[letter]
      assert_not_nil residue, residue_str
      assert_equal name, residue.name
      assert_in_delta mass, residue.mass, delta_mass, residue_str 
    end
  end
  
  # vs the Mascot Amino Acid Reference Data, 2008-01-11
  # http://hsc-mascot.uchsc.edu/mascot/help/aa_help.html
  #
  # minor formatting was done on this table to make it nice for the test;
  # the formatting consisted of condensing residue names and formula
  # to the same line and moving composites to a separate string. ex:
  #   Alanine
  #   C3H5NO  Ala   A   71.03712  71.08   Ala
  # became
  #   Alanine C3H5NO  Ala   A   71.03712  71.08   Ala
  #
  # Note there are minor capitalization differences in the names and 
  # abbreviations relative to those in Residue
  def test_mass_values_vs_mascot
    str = %Q{
Alanine C3H5NO  Ala   A   71.03712  71.08   Ala
Arginine C6H12N4O   Arg   R   156.10112   156.19  Arg
Asparagine C4H6N2O2   Asn   N   114.04293   114.10  Asn
Aspartic acid C4H5NO3   Asp   D   115.02695   115.09  Asp
Cysteine C3H5NOS  Cys   C   103.00919   103.14  Cys
Glutamic acid C5H7NO3   Glu   E   129.04260   129.12  Glu
Glutamine C5H8N2O2  Gln   Q   128.05858   128.13  Gln
Glycine C2H3NO  Gly   G   57.02147  57.05   Gly
Histidine C6H7N3O   His   H   137.05891   137.14  His
Isoleucine C6H11NO  Ile   I   113.08407   113.16  Ile
Leucine C6H11NO   Leu   L   113.08407   113.16  Leu
Lysine C6H12N2O   Lys   K   128.09497   128.17  Lys
Methionine C5H9NOS  Met   M   131.04049   131.19  Met
Phenylalanine C9H9NO  Phe   F   147.06842   147.18  Phe
Proline C5H7NO  Pro   P   97.05277  97.12   Pro
Serine C3H5NO2  Ser   S   87.03203  87.08   Ser
Threonine C4H7NO2   Thr   T   101.04768   101.10  Thr
Selenocysteine C3H5NOSe   SeC   U   150.95364   150.03  SeC
Tryptophan C11H10N2O  Trp   W   186.07932   186.21  Trp
Tyrosine C9H9NO2  Tyr   Y   163.06333   163.18  Tyr
Valine C5H9NO   Val   V   99.06842  99.13   Val}

    composites = %Q{
Asn or Asp  Asx   B      
Glu or Gln  Glx   Z 
Unknown   Xaa   X}

    residues = str.split(/\n/)
    residues.each do |residue_str|
      next if residue_str.empty?
      
      residue_str =~ /(.*)\s+([\w\d]+)\s+(\w\w\w)\s+(\w)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+\w\w\w/
      name = $1
      formula = $2
      abbr = $3
      letter = $4
      monoisotopic = $5.to_f
      average = $6.to_f

      residue = Residue[letter]
      assert_not_nil residue, residue_str
      assert_equal name.upcase, residue.name.upcase, residue_str
      assert_equal abbr.upcase, residue.abbr.upcase, residue_str
      assert_equal formula, residue.to_s.gsub(/\(|\)/, ""), residue_str
      
      assert_in_delta monoisotopic, residue.mass, delta_mass, residue_str 
      # TODO -- check average mass
    end
  end
  
  # vs the VG Analytical Organic Mass Spectrometry reference, reference date unknown (prior to 2005)
  # the data from the data sheet was copied manually to doc/VG Analytical DataSheet.txt
  def test_mass_values_vs_vg_analytical
    common = %Q{
Ala A Alanine C3H5NO 71.03711 71.0788
Arg R Arginine C6H12N4O 156.10111 156.1875
Asn N Asparagine C4H6N2O2 114.04293 114.1038
Asp D Aspartic Acid C4H5NO3 115.02694 115.0886
Cys C Cysteine C3H5NOS 103.00919 103.1388
Glu E Glutamic Acid C5H7NO3 129.04259 129.115
Gln Q Glutamine C5H8N2O2 128.05858 128.1307
Gly G Glycine C2H3NO 57.02146 57.0519
His H Histidine C6H7N3O 137.05891 137.1411
Ile I Isoleucine C6H11NO 113.08406 113.1594
Leu L Leucine C6H11NO 113.08406 113.1594
Lys K Lysine C6H12N2O 128.09496 128.1741
Met M Methionine C5H9NOS 131.04049 131.1926
Phe F Phenylalanine C9H9NO 147.06841 147.1766
Pro P Proline C5H7NO 97.05276 97.1167
Ser S Serine C3H5NO2 87.03203 87.0782
Thr T Threonine C4H7NO2 101.04768 101.1051
Trp W Tryptophan C11H10N2O 186.07931 186.2132
Tyr Y Tyrosine C9H9NO2 163.06333 163.1760
Val V Valine C5H9NO 99.06841 99.1326}

    residues = common.split(/\n/)
    residues.each do |residue_str|
      next if residue_str.empty?
      
      residue_str =~ /(\w\w\w) (\w) (\w+( Acid)?) ([\w\d]+) (\d+\.\d+) (\d+\.\d+)/
      abbr = $1
      letter = $2
      name = $3
      formula = $5
      monoisotopic = $6.to_f
      average = $7.to_f

      residue = Residue[letter]
      assert_not_nil residue, residue_str
      assert_equal name, residue.name, residue_str
      assert_equal abbr, residue.abbr, residue_str
      assert_equal formula, residue.to_s.gsub(/\(|\)/, ""), residue_str
      
      assert_in_delta monoisotopic, residue.mass, delta_mass, residue_str 
      # TODO -- check average mass
    end
    
    uncommon = %Q{
Orn Ornithine C5H10N2O 114.07931 114.1472
Aba Aminobutyric Acid C4H7NO 85.05276 85.1057
AECys Aminoethylcysteine C5H10N2OS 146.05138 146.2072
Aib alpha-Aminoisobutyric Acid C4H7NO 85.05276 85.1057
CMCys Carboxymethylcysteine C5H7NO3S 161.01466 161.1755
Dha Dehydroalanine C3H3NO 69.02146 69.0629
Dhb Dehydroamino-alpha-butyric Acid C4H5NO 83.03711 83.0898
Hyl Hydroxylysine C6H12N2O2 144.08988 144.1735
Hyp Hydroxyproline C5H7NO2 113.04768 113.1161
Iva Isovaline C5H9NO 99.06841 99.1326
nLeu Norleucine C6H11NO 113.08406 113.1594
Pip 2-Piperidinecarboxylic Acid C6H9NO 111.06841 111.1436
pGlu Pyroglutamic Acid C5H5NO2 111.03203 111.1002
Sar Sarcosine C3H5NO 71.03711 71.0788}

    residues = uncommon.split(/\n/)
    residues.each do |residue_str|
      next if residue_str.empty?
      
      residue_str =~ /(\w+) ([\w-]+( Acid)?) ([\w\d]+) (\d+\.\d+) (\d+\.\d+)/
      abbr = $1
      name = $2
      formula = $4
      monoisotopic = $5.to_f
      average = $6.to_f
      
      residue = Residue[abbr]
      assert_not_nil residue, residue_str
      assert_equal name, residue.name, residue_str
      assert_equal formula, residue.to_s.gsub(/\(|\)/, ""), residue_str
      
      assert_in_delta monoisotopic, residue.mass, delta_mass, residue_str 
      # TODO -- check average mass
    end
  end
  
end