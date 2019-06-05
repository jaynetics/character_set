require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'rake/extensiontask'

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

desc 'Download relevant ruby/spec tests, adapt to CharacterSet and its variants'
task :sync_ruby_spec do
  require 'fileutils'

  variants = {
    'CharacterSet'       => './spec/ruby-spec/library/character_set',
    'CharacterSet::Pure' => './spec/ruby-spec/library/character_set_pure',
  }

  # download fresh specs from ruby/spec repository
  variants.each do |_, dir|
    FileUtils.rm_rf(dir) if File.exist?(dir)
    `svn export https://github.com/ruby/spec/trunk/library/set/sortedset #{dir}`
  end

  # make copies for each CharacterSet variant
  base = variants.first[1]
  variants.each_value { |dir| FileUtils.copy_entry(base, dir) unless dir == base }

  # adapt specs to work with CharacterSet
  variants.each do |class_name, dir|
    Dir["#{dir}/**/*.rb"].each do |spec|
      # ignore some tests that do not apply or are covered otherwise
      if spec =~ %r{/(classify|divide|flatten|initialize|pretty_print)}
        File.delete(spec)
        next
      end

      adapted_content =
        File.read(spec).
        # adapt class name
        gsub('SortedSet', (spec['/shared/'] ? 'variant' : class_name)).
        gsub(/(it_behaves_like :[^,\n]+), (:[^,\n]+)/, "\\1, #{class_name}, \\2").
        # get shared specs from a single shared dir at the parent level
        gsub(/(require_relative ['"])(shared\/)/, '\1../\2').
        # make 'mspec' syntax rspec-compatible
        gsub(/describe (.*), shared.*$/, 'shared_examples \1 do |variant, method|').
        gsub(/be_(false|true)/, 'be \1').
        gsub('stub!', 'stub').
        gsub('mock', 'double').
        gsub('@method', 'method').
        # remove unneeded requires
        gsub(/require 'set'\n/, '').
        gsub(/require.*spec_helper.*\n/, '').
        gsub(/\A\n+/, '').
        # make examples use Integers/codepoints
        gsub(/1\.0|"cat"|"dog"|"hello"|"test"/, '0').
        gsub('"one"', '1').
        gsub('"two"', '2').
        gsub('"three"', '3').
        gsub('"four"', '4').
        gsub('"five"', '5').
        gsub(/x.(size|length) == 3/, 'x != 3').
        gsub(/x.(size|length) != 3/, 'x == 3').
        gsub(/(add)\(\d\)(\.to_a \}.should raise)/, '\1(:foo)\2')

      File.open(spec, 'w') { |f| f.puts adapted_content }
    end
  end

  # keep only one copy of the shared specs, at the parent level
  FileUtils.rm_rf(base + '/../shared')
  FileUtils.mv(base + '/shared', base + '/../')
  variants.each_value { |dir| FileUtils.rm_rf(dir + '/shared') }
end

desc 'Download unicode casefold data and write new C header file'
task :sync_casefold_data do
  src_path = './CaseFolding.txt'
  dst_path = './ext/character_set/unicode_casefold_table.h'

  `wget http://www.unicode.org/Public/UNIDATA/CaseFolding.txt`

  mapping = File.foreach(src_path).each_with_object({}) do |line, hash|
    from, type, to = line.split(/\s*;\s*/).first(3)
    # type 'C' stands for 'common', excludes mappings to multiple chars
    hash[from] = to if type == 'C'
  end.sort

  content = File.read(dst_path + '.tmpl')
    .sub(/(CASEFOLD_COUNT )0/, "\\1#{mapping.count}")
    .sub('{}', ['{', mapping.map { |a, b| "{0x#{a},0x#{b}}," }, '}'].join("\n"))

  File.write(dst_path, content)
  File.unlink(src_path)
end

desc 'Update codepoint data for predefined sets, based on Onigmo'
task :sync_predefined_sets do
  %w[assigned emoji whitespace].each do |prop|
    require 'regexp_property_values'
    ranges = RegexpPropertyValues[prop].matched_ranges
    str = ranges.map { |r| "#{r.min.to_s(16)},#{r.max.to_s(16)}\n" }.join.upcase
    File.write("./lib/character_set/predefined_sets/#{prop}.cps", str, mode: 'w')
  end
end

desc 'Run all IPS benchmarks'
task :benchmark do
  Dir['./benchmarks/*.rb'].sort.each { |file| require file }
end

namespace :benchmark do
  desc 'Run all IPS benchmarks and store the comparison results in BENCHMARK.md'
  task :write_to_file do
    $store_comparison_results = {}

    Rake.application[:benchmark].invoke

    File.open('BENCHMARK.md', 'w') do |f|
      f.puts "Results of `rake:benchmark` on #{RUBY_DESCRIPTION}", ''

      $store_comparison_results.each do |caption, result|
        f.puts '```', caption, '',
               result.strip.gsub(/(same-ish).*$/, '\1').lines[1..-1], '```'
      end
    end
  end
end

unless RUBY_PLATFORM =~ /java/
  # recompile before benchmarking or running specs
  task(:benchmark).enhance([:compile])
  task(:spec).enhance([:compile])
end
