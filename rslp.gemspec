require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name        = 'rslp'
  spec.version     = '0.0.1'
  spec.license     = 'Apache-2.0'
  spec.author      = 'Daniel J. Berger'
  spec.email       = 'djberg96@gmail.com'
  spec.homepage    = 'https://github.com/djberg96/rslp'
  spec.summary     = 'Interface for the OpenSLP library'
  spec.test_files  = Dir['spec/*.rb']
  spec.files       = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['README.md', 'CHANGES.md', 'MANIFEST.md', 'LICENSE']

  spec.add_dependency('ffi', "~> 1.9.8")

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', "~> 3.9")

  spec.description = <<-EOF
    The rslp library is an FFI interface for the OpenSLP service
    location protocol library.
  EOF
end
