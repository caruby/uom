require 'uom'

SPEC = Gem::Specification.new do |s|
  s.name          = "uom"
  s.summary       = "Ruby Unit of Measurement library." 
  s.description   = <<-eof
    UOM implements Units of Measurement based on the International System of Units (SI).
    The base SI units, metric scalar factors and all possible combinations of these units
    are supported out of the box.
  eof
  s.version       = UOM::VERSION
  s.date          = "2010-09-30"
  s.author        = "OHSU"
  s.email         = "loneyf@ohsu.edu"
  s.homepage      = "http://github.com/caruby/uom/"
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir.glob("{doc,lib}/**/*") + Dir.glob("test/{lib}/**/*") + ['History.txt', 'LEGAL', 'LICENSE', 'README.md']
  s.require_paths = ['lib']
  s.add_dependency('extensional')
  s.has_rdoc      = 'uom'
  s.rubyforge_project = 'caruby'
end