# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'javy_tool/version'

Gem::Specification.new do |gem|
  gem.name          = "javy_tool"
  gem.version       = JavyTool::VERSION
  gem.authors       = ["javy_liu"]
  gem.licenses      = ["MIT"]
  gem.email         = ["javy_liu@163.com"]
  gem.description   = %q{pack some used methods}
  gem.summary       = %q{some methods ofen used in my projects}
  gem.homepage      = "https://github.com/javyliu/javy_tool"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  #s.add_dependency "rails", "~> 3.2.6"
end
