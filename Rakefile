require File.dirname(__FILE__) + '/lib/uom'
require 'rbconfig'

UOM::VERSION.replace(ENV['UOM_VERSION']) if ENV['UOM_VERSION']
WINDOWS = (Config::CONFIG['host_os'] =~ /mingw|win32|cygwin/ ? true : false) rescue false
SUDO = WINDOWS ? '' : 'sudo'

desc "Builds the gem"
task :gem do
  load 'UOM.gemspec'
  Gem::Builder.new(SPEC).build
end

desc "Installs the gem"
task :install => :gem do
  sh "#{SUDO} gem install uom-#{UOM::VERSION}.gem --no-rdoc --no-ri"
end
