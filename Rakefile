require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rake/clean'

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx', '**/*.lock')

namespace 'gem' do
  desc "Create the rslp gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('rslp.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the rslp gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc "Setup the openslp docker container"
task :docker do
  if RbConfig::CONFIG['host'] =~ /macos|darwin/i
    sh "docker desktop start"
    sh "docker run -d -p 427:427/tcp -p 427:427/udp vcrhonek/openslp"
  else
    sh "sudo systemctl start docker"
    sh "sudo docker run -d -p 427:427/tcp -p 427:427/udp vcrhonek/openslp"
  end
end

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

# Clean up afterwards
Rake::Task[:spec].enhance do
  Rake::Task[:clean].invoke
end

task :default => :spec
