version_header = File.read('ext/ruby_prof/version.h')
match = version_header.match(/RUBY_PROF_VERSION\s*["](\d.+)["]/)
raise(RuntimeError, "Could not determine RUBY_PROF_VERSION") if not match
version = match[1]

FILES = Dir[
  'Rakefile',
  'README',
  'LICENSE',
  'CHANGES',
  'bin/*',
  'doc/**/*',
  'examples/*',
  'ext/ruby_prof/*.c',
  'ext/ruby_prof/*.h',
  'ext/ruby_prof/mingw/Rakefile',
  'ext/ruby_prof/mingw/build.rake',
  'ext/vc/*.sln',
  'ext/vc/*.vcproj',
  'lib/**/*',
  'rails/**/*',
  'test/*'
]

Gem::Specification.new do |spec|
  spec.name = "ruby-prof"
  
  spec.homepage = "http://rubyforge.org/projects/ruby-prof/"
  spec.summary = "Fast Ruby profiler"
  spec.description = <<-EOF
ruby-prof is a fast code profiler for Ruby. It is a C extension and
therefore is many times faster than the standard Ruby profiler. It
supports both flat and graph profiles.  For each method, graph profiles
show how long the method ran, which methods called it and which 
methods it called. RubyProf generate both text and html and can output
it to standard out or to a file.
EOF

  spec.version = version

  spec.author = "Shugo Maeda, Charlie Savage, Roger Pack"
  spec.email = "shugo@ruby-lang.org, cfis@savagexi.com, rogerdpack@gmail.com"
  spec.platform = Gem::Platform::RUBY
  spec.require_path = "lib" 
  spec.bindir = "bin"
  spec.executables = ["ruby-prof"]
  spec.extensions = ["ext/ruby_prof/extconf.rb"]
  spec.files = FILES.to_a
  spec.test_files = Dir["test/test_*.rb"]
  spec.required_ruby_version = '>= 1.8.4'
  spec.date = DateTime.now
  spec.rubyforge_project = 'ruby-prof'
  spec.add_development_dependency 'os'
  spec.add_development_dependency 'rake-compiler'
  
end
