# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cukeforker/version"

Gem::Specification.new do |s|
  s.name        = "cukeforker"
  s.version     = CukeForker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken", "Wallace Harwood", "Jarod Adair"]
  s.email       = ["jari.bakken@gmail.com", "wallaceh@gmail.com", "adairjk@gmail.com" ]
  s.homepage    = ""
  s.summary     = %q{Library to maintain a forking queue of Cucumber processes}
  s.description = %q{Library to maintain a forking queue of Cucumber processes, with optional VNC displays.}

  s.rubyforge_project = "cukeforker"

  s.add_dependency "cucumber", ">= 2.0.0"
  s.add_dependency "vnctools", ">= 0.0.5"
  s.add_development_dependency "rspec", "~> 2.5"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "rake", "~> 0.9.2"
  s.add_development_dependency "pry"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
