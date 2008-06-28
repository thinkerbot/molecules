Gem::Specification.new do |s|
	s.name = "molecule"
	s.version = "0.1.0"
	s.author = "Simon Chiang"
	s.email = "simon.a.chiang@gmail.com"
	s.homepage = "http://bioactive.rubyforge.org/molecules/"
	s.platform = Gem::Platform::RUBY
	s.summary = "A library of molecules for scientific calculations in Ruby."
  s.rubyforge_project = "bioactive"
	s.files = %w{
    MIT-LICENSE
    Rakefile
    README
	}
	
	s.require_path = "lib"
	s.test_file = "test/molecules_test_suite.rb"
	
	s.has_rdoc = true
	s.extra_rdoc_files = ["README", 'MIT-LICENSE']
  s.add_dependency("bahuvrihi-constants", ">=0.1.0")
end
