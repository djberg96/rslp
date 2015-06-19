require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |gem|
  gem.name       = 'rslp'
  gem.version    = '0.1.0'
  gem.license    = 'Apache 2.0'
  gem.author     = 'Daniel J. Berger'
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'https://github.com/djberg96/rslp'
  gem.summary    = 'Interface for the OpenSLP library'
  gem.test_files = Dir['spec/*.rb']
  gem.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST', 'LICENSE']

  gem.add_dependency('ffi', "~> 1.9.8")

  gem.add_development_dependency('rake', "~> 10.0")
  gem.add_development_dependency('rspec', "~> 3.0")

  gem.description = <<-EOF
    The rslp library is an FFI interface for the OpenSLP service
    location protocol library.
  EOF
end
