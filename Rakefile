$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'uom'
require 'rbconfig'

GEM = 'uom'
GEM_VERSION = UOM::VERSION
GEM_VERSION.replace(ENV['UOM_VERSION']) if ENV['UOM_VERSION']

WINDOWS = (Config::CONFIG['host_os'] =~ /mingw|win32|cygwin/ ? true : false) rescue false
SUDO = WINDOWS ? '' : 'sudo'

# the archive include files
TAR_FILES = Dir.glob("{bin,lib,sql,*.gemspec,doc/website,test/{bin,fixtures,lib}}") +
  ['.gitignore', 'History.txt', 'LEGAL', 'LICENSE', 'Rakefile', 'README.md']

desc "Builds the gem"
task :gem do
  load "#{GEM}.gemspec"
  Gem::Builder.new(SPEC).build
end

desc "Installs the gem"
task :install => :gem do
  sh "#{SUDO} gem install #{GEM}-#{GEM_VERSION}.gem"
end

desc "Archives the source"
task :tar do
  if WINDOWS then
    sh "echo Windows archive not supported"
  else
    sh "tar -czf #{GEM}-#{GEM_VERSION}.tar.gz #{TAR_FILES.join(' ')}"
  end
end