# frozen_string_literal: true

require 'rake/clean'
require 'tmpdir'

# Build the JRuby extension without runtime downloads.
module CharacterSetJavaBuild
  ROOT = File.expand_path('..', __dir__)
  SOURCES = FileList[File.join(ROOT, 'ext/character_set/java/src/main/java/**/*.java')]
  JAR = 'lib/character_set/character_set.jar'
  BUILD = File.join(ROOT, 'tmp/java')

  def self.tool(name)
    ENV['JAVA_HOME'] ? File.join(ENV['JAVA_HOME'], 'bin', name) : name
  end

  def self.jruby_jar
    path = ENV['JRUBY_JAR'] || File.join(RbConfig::CONFIG['prefix'], 'lib/jruby.jar')
    abort 'Java compilation needs JRuby. Run with JRuby or set JRUBY_JAR to its lib/jruby.jar.' unless File.file?(path)
    path
  end
end

CLEAN.include(CharacterSetJavaBuild::BUILD, CharacterSetJavaBuild::JAR)

file CharacterSetJavaBuild::JAR => CharacterSetJavaBuild::SOURCES.to_a + [__FILE__] do
  build = CharacterSetJavaBuild::BUILD
  classes = File.join(build, 'classes')
  rm_rf classes, verbose: false
  mkdir_p classes, verbose: false

  # Compile against JRuby without shipping JRuby or its dependencies in our JAR.
  sh CharacterSetJavaBuild.tool('javac'), '--release', '21', '-proc:none',
     '-classpath', CharacterSetJavaBuild.jruby_jar, '-d', classes,
     *CharacterSetJavaBuild::SOURCES.to_a

  sh CharacterSetJavaBuild.tool('jar'), '--create', '--file', CharacterSetJavaBuild::JAR,
     '-C', classes, '.'
end

namespace :java do
  desc 'Compile the JRuby backend (requires a JDK and JRuby, or JRUBY_JAR)'
  task compile: CharacterSetJavaBuild::JAR

  desc 'Verify that CharacterSet uses the Java backend'
  task verify_backend: :compile do
    check = 'abort "Java backend not active" unless ' \
            'CharacterSet.new.to_java.java_class.name == "org.jaynetics.characterset.RubyCharacterSet"'
    ruby '-Ilib', '-rcharacter_set', '-rjava', '-e',
         check
  end

  desc 'Install and exercise the Java gem outside the checkout'
  task smoke: :gem do
    abort 'Run java:smoke with JRuby' unless RUBY_ENGINE == 'jruby'
    artifact = File.join(CharacterSetJavaBuild::ROOT, 'pkg', "character_set-#{CharacterSet::VERSION}-java.gem")

    Dir.mktmpdir('character-set-java-smoke') do |directory|
      gems = File.join(directory, 'gems')
      environment = { 'GEM_HOME' => gems, 'GEM_PATH' => gems, 'RUBYLIB' => nil,
                      'RUBYOPT' => nil, 'BUNDLE_GEMFILE' => nil }
      sh environment, Gem.ruby, '-S', 'gem', 'install', '--local',
         '--no-document', '--install-dir', gems, artifact, chdir: directory
      script = File.join(CharacterSetJavaBuild::ROOT, 'tasks/java_smoke.rb')
      sh environment, Gem.ruby, script, directory, chdir: directory
    end
  end
end
