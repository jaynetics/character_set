# frozen_string_literal: false

require 'fileutils'
require 'open3'
require 'tmpdir'

describe 'CharacterSet Java loading', if: RUBY_ENGINE == 'jruby' && !ENV['QUICK_SPEC_RUN'] do
  def with_library_copy
    Dir.mktmpdir('character-set-java-loading') do |directory|
      library = File.join(directory, 'lib')
      FileUtils.cp_r(File.expand_path('../../lib', __dir__), library)
      yield library
    end
  end

  def run_isolated(library, script)
    environment = { 'RUBYOPT' => nil, 'RUBYLIB' => nil, 'BUNDLE_GEMFILE' => nil }
    # A second library directory may contain a JAR. An unbuilt checkout must
    # select its Ruby fallback rather than accidentally require that other JAR.
    root_library = File.expand_path('../../lib', __dir__)
    script = "$LOAD_PATH << ARGV.fetch(0); #{script}"
    Open3.capture3(environment, Gem.ruby, '-I', library, '-e', script, root_library,
                   chdir: File.dirname(library))
  end

  it 'uses the Ruby fallback in an unbuilt checkout' do
    with_library_copy do |library|
      File.unlink(File.join(library, 'character_set/character_set.jar'))
      script = 'require "character_set"; ' \
               'abort unless CharacterSet.ancestors.include?(CharacterSet::RubyFallback); ' \
               'abort unless CharacterSet[97].count_in("aa") == 2'
      _stdout, stderr, status = run_isolated(library, script)
      expect(status.success?).to be(true), stderr
    end
  end

  it 'does not silently fall back when an installed Java artifact is broken' do
    with_library_copy do |library|
      File.binwrite(File.join(library, 'character_set/character_set.jar'), 'not a JAR')
      script = 'require "character_set"; puts "silently loaded"'
      stdout, _stderr, status = run_isolated(library, script)
      expect(status.success?).to be false
      expect(stdout).not_to include 'silently loaded'
    end
  end
end
