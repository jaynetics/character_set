require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rake/extensiontask'

Dir['tasks/**/*.rake'].each { |file| load(file) }

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :spec do
  task :quick do
    ENV['SKIP_MEMSAFETY_SPECS'] = '1'
    Rake::Task[:spec].invoke
  end
end

Rake::ExtensionTask.new('character_set') do |ext|
  ext.lib_dir = 'lib/character_set'
end

namespace :java do
  java_gemspec = eval File.read('./character_set.gemspec')
  java_gemspec.platform = 'java'
  java_gemspec.extensions = []

  java_gemspec.add_runtime_dependency 'range_compressor', '~> 1.0'

  Gem::PackageTask.new(java_gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
    pkg.package_dir = 'pkg'
  end
end

task package: 'java:gem'

unless RUBY_PLATFORM =~ /java/
  # recompile before benchmarking or running specs
  task(:benchmark).enhance([:compile])
  task(:spec).enhance([:compile])
end
