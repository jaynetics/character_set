require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'rake/extensiontask'

Rake::ExtensionTask.new('character_set') do |ext|
  ext.lib_dir = 'lib/character_set'
end

unless RUBY_PLATFORM =~ /java/
  # recompile before benchmarking or running specs
  task(:spec).enhance([:compile])
end

desc 'Download relevant ruby/spec tests, adapt to CharacterSet and its variants'
task :sync_ruby_spec do
  require 'fileutils'

  variants = {
    'CharacterSet'       => './spec/ruby-spec/library/character_set',
    'CharacterSet::Pure' => './spec/ruby-spec/library/character_set_pure',
  }
  variants.each do |_, dir|
    FileUtils.rm_rf(dir) if File.exist?(dir)
    `svn export https://github.com/ruby/spec/trunk/library/set/sortedset #{dir}`
  end

  base = variants.first[1]
  variants.each_value { |dir| FileUtils.copy_entry(base, dir) unless dir == base }

  variants.each.with_index do |(class_name, dir), i|
    Dir["#{dir}/**/*.rb"].each do |spec|
      # remove some tests that do not apply or are covered otherwise
      if spec =~ %r{/(flatten|initialize|pretty_print)}
        File.delete(spec)
        next
      end

      # some examples w. Strings must be adapted, "mspec" made rspec-compatible,
      # and `i` added to shared example names or they'll override each other
      adapted_content =
        File
        .read(spec)
        .gsub('SortedSet', class_name)
        .gsub('sorted_set_', "sorted_set_#{i}_")
        .gsub(/describe (.*), shared.*$/, 'shared_examples \1 do |method|')
        .gsub(/1\.0|"cat"|"dog"|"hello"|"test"/, '0')
        .gsub('"one"', '1')
        .gsub('"two"', '2')
        .gsub('"three"', '3')
        .gsub('"four"', '4')
        .gsub('"five"', '5')
        .gsub('@method', 'method')
        .gsub(/be_(false|true)/, 'be \1')
        .gsub('mock', 'double')

      File.open(spec, 'w') { |f| f.puts adapted_content }
    end
  end
end
