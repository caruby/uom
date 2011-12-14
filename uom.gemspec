require 'date'
require File.expand_path('version', File.dirname(__FILE__) + '/lib/uom')

Gem::Specification.new do |s|
  s.name          = "uom"
  s.summary       = "Ruby Unit of Measurement library." 
  s.description   = <<-eof
    UOM implements Units of Measurement based on the International System of Units (SI).
    The base SI units, metric scalar factors and all possible combinations of these units
    are supported out of the box.
  eof
  s.version       = UOM::VERSION
  s.date          = Date.today
  s.author        = "OHSU"
  s.email         = "caruby.org@gmail.com"
  s.homepage      = "http://github.com/caruby/uom/"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{lib}/**/*") + Dir.glob("test/lib/**/*") + ['History.md', 'LEGAL', 'LICENSE', 'README.md']
  s.test_files    = Dir['test/lib/**/*test.rb']
  s.require_path  = 'lib'
  s.add_dependency('extensional')
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
  s.has_rdoc      = 'yard'
  s.license       = 'MIT'
  s.rubyforge_project = 'caruby'
end
