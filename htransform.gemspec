# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "htransform/version"

Gem::Specification.new do |s|
  s.name        = "htransform"
  s.version     = HTransform::VERSION
  s.authors     = ["Josh Krueger"]
  s.email       = ["joshsinbox@gmail.com"]
  s.homepage    = "https://github.com/joshkrueger/htransform"
  s.summary     = %q{HTransform transforms your hashes}
  s.description = %q{HTransform provides a simple DSL to transform arbitrary hashes into another, more arbitrary hash. Yay.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec", "~> 2.5.0")
  s.add_development_dependency("rake")
end
