require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'yaml'

# tasks
desc 'Default: Run tests.'
task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = File.join('test', ENV['subset'] || '', ENV['pattern'] || '**/*_test.rb')
  t.verbose = true
end

#
# admin tasks
#

def gemspec
  data = File.read("molecules.gemspec")
  spec = nil
  Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
  spec
end

task :print_manifest do
  gemspec.files.each do |file| 
    puts("%-5s : %s" % [File.exists?(file), file])
  end
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "molecules"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include(["README", 'MIT-LICENSE'])
  rdoc.rdoc_files.include(gemspec.files.select {|file| file =~ /^lib/})
end

desc "Publish RDoc to RubyForge"
task :publish_rdoc => [:rdoc] do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  
  rsync_args = "-v -c -r"
  remote_dir = "/var/www/gforge-projects/bioactive/molecules"
  local_dir = "rdoc"
 
  sh %{rsync #{rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end
