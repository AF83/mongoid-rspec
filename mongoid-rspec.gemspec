# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid-rspec/version"

Gem::Specification.new do |s|
  s.name        = "mongoid-rspec"
  s.version     = Mongoid::Rspec::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Evan Sagge", "Mauricio Gomes"]
  s.email       = %q{mauricio@edge14.com}
  s.homepage    = %q{http://github.com/mgomes/mongoid-rspec}
  s.summary     = %q{RSpec matchers for Mongoid 4.x}
  s.description = %q{RSpec matches for Mongoid 4.x models, including association and validation matchers}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rake', '~> 10.1.0'
  s.add_dependency 'mongoid', '~> 4.0.0'
  s.add_dependency 'rspec', '>= 2.14'
end
