Gem::Specification.new do |s|
  s.name = "molecules"
  s.version = "0.2.0"
  s.author = "Simon Chiang"
  s.email = "simon.a.chiang@gmail.com"
  s.homepage = "http://bioactive.rubyforge.org/molecules/"
  s.platform = Gem::Platform::RUBY
  s.summary = "A library of molecules for scientific calculations in Ruby."
  s.rubyforge_project = "bioactive"
  s.require_path = "lib"
  s.add_dependency("constants", ">= 0.1.0")
  s.add_development_dependency("tap", ">= 0.17.0")
  s.add_development_dependency("tap-test", ">= 0.1.0")
  
  s.has_rdoc = true
  s.extra_rdoc_files = %w{
    README
    MIT-LICENSE
  }
  
  s.files = %w{
    lib/molecules.rb
    lib/molecules/calc.rb
    lib/molecules/empirical_formula.rb
    lib/molecules/libraries/polypeptide.rb
    lib/molecules/libraries/residue.rb
    lib/molecules/utils.rb
    tap.yml
  }
  
end
