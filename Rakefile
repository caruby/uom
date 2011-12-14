require File.expand_path('version', File.dirname(__FILE__) + '/lib/uom')

# the gem name
GEM = 'uom'
GEM_VERSION = UOM::VERSION

WINDOWS = (Config::CONFIG['host_os'] =~ /mingw|win32|cygwin/ ? true : false) rescue false
SUDO = WINDOWS ? '' : 'sudo'

# the archive include files
TAR_FILES = Dir.glob("{lib,*.gemspec,doc}") +
  ['.gitignore', 'LEGAL', 'LICENSE', 'Rakefile', 'README.md']

desc "Builds the gem"
task :gem do
  sh "gem build #{GEM}.gemspec"
end

desc "Installs the gem"
task :install => :gem do
  sh "#{SUDO} gem install #{GEM}-#{GEM_VERSION}.gem"
end

desc "Runs all tests"
task :test do
  Dir[File.dirname(__FILE__) + '/**/test/**/*_test.rb'].each { |f| system('jruby', f) }
end

desc "Archives the source"
task :tar do
  if WINDOWS then
    sh "zip -r #{GEM}-#{GEM_VERSION}.zip #{TAR_FILES.join(' ')}"
  else
    sh "tar -czf #{GEM}-#{GEM_VERSION}.tar.gz #{TAR_FILES.join(' ')}"
  end
end
