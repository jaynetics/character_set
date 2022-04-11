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

# WIP - build encoding cp lists
require 'character_set'
require 'range_compressor'

enc_names = Encoding.list.map(&:name).sort
hash = {}
full_s = CharacterSet.valid.map { |cp| cp.chr('utf-8') }.join; 1
enc_names.each do |name|
  enc_s = full_s.encode(name, invalid: :replace, undef: :replace, replace: '')
  enc_cs = CharacterSet.of(enc_s)
  cp_str = enc_cs.ranges.map { |r| "#{r.min.to_s(16)},#{r.max.to_s(16)}\n" }.join.upcase
  hash[name] = cp_str
rescue => e
  hash[name] = e
end

good = hash.select { |k, v| !v.is_a?(Exception) }; 1
shared = good.keys.group_by { |k| good[k] }.map { |k, v| [v, k] }.to_h
