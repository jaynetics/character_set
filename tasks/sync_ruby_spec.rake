desc 'Download relevant ruby/spec tests, adapt to CharacterSet and its variants'
task :sync_ruby_spec do
  require 'fileutils'

  variants = {
    'CharacterSet'       => "#{__dir__}/../spec/ruby-spec/library/character_set",
    'CharacterSet::Pure' => "#{__dir__}/../spec/ruby-spec/library/character_set_pure",
  }

  # download fresh specs from ruby/spec repository
  variants.each do |_, dir|
    FileUtils.rm_rf(dir)
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
