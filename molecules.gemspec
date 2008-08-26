Gem::Specification.new do |s|
	s.name = "molecules"
	s.version = "0.1.1"
	s.author = "Simon Chiang"
	s.email = "simon.a.chiang@gmail.com"
	s.homepage = "http://bioactive.rubyforge.org/molecules/"
	s.platform = Gem::Platform::RUBY
	s.summary = "A library of molecules for scientific calculations in Ruby."
  s.rubyforge_project = "bioactive"
  s.require_path = "lib"
  s.add_dependency("constants", ">=0.1.0")
	s.test_file = "test/molecules_test_suite.rb"
	s.has_rdoc = true
  s.extra_rdoc_files = %w{
    README
    MIT-LICENSE
  }
  
	s.files = %w{
    MIT-LICENSE
    Rakefile
    README
    lib/molecules.rb
    lib/molecules/calc.rb
    lib/molecules/empirical_formula.rb
    lib/molecules/libraries/polypeptide.rb
    lib/molecules/libraries/residue.rb
    lib/molecules/utils.rb
    tap.yml
    test/molecules/calc_test.rb
    test/molecules/empirical_formula_class_test.rb
    test/molecules/empirical_formula_test.rb
    test/molecules/libraries/polypeptide_test.rb
    test/molecules/libraries/residue_test.rb
    test/molecules/utils_test.rb
    test/molecules_test.rb
    test/molecules_test_helper.rb
    test/molecules_test_suite.rb
    test/tap_test_helper.rb
	}
	
end
