# frozen_string_literal: false

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rake/extensiontask'

Dir['tasks/**/*.rake'].each { |file| load(file) }

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :spec do
  task :quick do
    ENV['QUICK_SPEC_RUN'] = '1'
    Rake::Task[:spec].invoke
  end
end

Rake::ExtensionTask.new('character_set') do |ext|
  ext.lib_dir = 'lib/character_set'
end

namespace :java do
  java_gemspec = Gem::Specification.load('./character_set.gemspec')
  java_gemspec.platform = 'java'
  java_gemspec.extensions = []
  java_gemspec.required_ruby_version = '>= 3.1'
  java_gemspec.files |= ['lib/character_set/java.rb', 'lib/character_set/character_set.jar']

  Gem::PackageTask.new(java_gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
    pkg.package_dir = 'pkg'
  end
end

Rake::Task['java:gem'].enhance(['java:compile'])

task package: 'java:gem'

if RUBY_ENGINE == 'jruby'
  task(:benchmark).enhance(['java:compile'])
  task(:spec).enhance(['java:compile', 'java:verify_backend'])
else
  # recompile before benchmarking or running specs
  task(:benchmark).enhance([:compile])
  task(:spec).enhance([:compile])
end
