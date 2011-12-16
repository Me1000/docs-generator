lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'ember_docs/version'

Gem::Specification.new do |s|
  s.name        = "ember-docs"
  s.version     = EmberDocs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Majd Taby", "Peter Wagenet"]
  s.email       = ["majd@sproutcore.com", "peter.wagenet@gmail.com"]
  s.homepage    = "http://sproutcore.com"
  s.summary     = %q{Docs Generator for Ember}
  s.description = %q{A tool to generate docs for Ember and Ember applications.}

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "thor"
  s.add_dependency "rack"

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = %w(ember-docs)
  s.require_paths      = ["lib"]
end


