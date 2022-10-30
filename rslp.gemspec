require 'rubygems'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name       = 'rslp'
  spec.version    = '0.1.1'
  spec.license    = 'Apache-2.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/rslp'
  spec.summary    = 'Interface for the OpenSLP library'
  spec.test_files = Dir['spec/*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['README.md', 'CHANGES.md', 'MANIFEST.md', 'LICENSE']

  spec.add_dependency('ffi', "~> 1.1")

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rubocop', '~> 1.37.1')
  spec.add_development_dependency('rubocop-rspec', '~> 2.14.2')

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/rslp',
    'bug_tracker_uri'       => 'https://github.com/djberg96/rslp/issues',
    'changelog_uri'         => 'https://github.com/djberg96/rslp/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/rslp/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/rslp',
    'wiki_uri'              => 'https://github.com/djberg96/rslp/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.description = <<-EOF
    The rslp library is an FFI interface for the OpenSLP service location
    protocol library. See http://www.openslp.org for more information.
  EOF
end
