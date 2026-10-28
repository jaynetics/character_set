# frozen_string_literal: false

require 'fileutils'
require 'json'
require 'open3'
require 'tmpdir'

# Workers prepend their selected library after Bundler setup, so the fallback
# uses the public CharacterSet API without CharacterSet::Pure adapter overhead.
if ARGV.first == 'worker'
  $LOAD_PATH.delete(File.expand_path('../lib', __dir__))
  $LOAD_PATH.unshift(ARGV.fetch(1))
  require 'character_set'
  require 'java'

  expected = ARGV.fetch(2)
  java_backend = CharacterSet.new.to_java.java_class.name == 'org.jaynetics.characterset.RubyCharacterSet'
  actual = java_backend ? 'java' : 'fallback'
  abort "Expected #{expected}, loaded #{actual}" unless expected == actual

  warmup = Float(ENV.fetch('WARMUP', '10'))
  duration = Float(ENV.fetch('TIME', '3'))
  abort 'WARMUP must be nonnegative and TIME must be positive' if warmup.negative? || duration <= 0

  mixed = ('ab cd ü 😋 ' * 1024).freeze
  ascii = ('ab cd ' * 2048).freeze
  utf16 = mixed.encode('UTF-16LE').freeze
  letters = CharacterSet['a', 'b', 'ü', '😋']
  absent = CharacterSet['z']
  complete = CharacterSet.of_string(mixed)
  a = CharacterSet.new(0..0xFFFF)
  b = CharacterSet.new(0x8000..0x1FFFF)
  recipient = CharacterSet.new(0..0x3FFF)
  source = CharacterSet.new(0x4000..0x7FFF)
  cases = {
    'membership' => [-> { letters.include?(97) }, true],
    'count_ascii' => [-> { letters.count_in(ascii) }, 4096],
    'count_mixed' => [-> { letters.count_in(mixed) }, 4096],
    'count_utf16' => [-> { letters.count_in(utf16) }, 4096],
    'keep_mixed' => [-> { letters.keep_in(mixed) }, 'abü😋' * 1024],
    'filter_unchanged' => [-> { complete.keep_in(mixed) }, mixed],
    'cover_first' => [-> { letters.cover?(mixed) }, false],
    'detect_absent' => [-> { absent.used_by?(mixed) }, false],
    'union_dense' => [-> { (a | b).size }, 0x20000],
    'merge_reset' => [-> { recipient.merge(source).subtract(source).size }, 0x4000]
  }
  selected = ENV.fetch('CASES', nil)&.split(',')
  abort "Unknown cases: #{selected - cases.keys}" if selected && !(selected - cases.keys).empty?
  cases.select! { |name, _| selected.include?(name) } if selected

  bean = java.lang.management.ManagementFactory.get_thread_mx_bean
  thread = java.lang.Thread.current_thread.get_id
  allocated = lambda do
    bean.respond_to?(:get_thread_allocated_bytes) ? bean.get_thread_allocated_bytes(thread) : nil
  end
  results = {}
  cases.each do |name, (operation, expected_value)|
    abort "Incorrect #{actual} result for #{name}" unless operation.call == expected_value
    rates = []
    allocation = nil
    [warmup, duration].each_with_index do |seconds, index|
      next if seconds.zero?

      count = 0
      before_bytes = allocated.call
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      loop do
        256.times { operation.call }
        count += 256
        break if Process.clock_gettime(Process::CLOCK_MONOTONIC) - start >= seconds
      end
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      after_bytes = allocated.call
      next unless index == 1

      rates << count / elapsed
      allocation = (after_bytes - before_bytes).to_f / count if before_bytes && after_bytes
    end
    abort "Incorrect #{actual} result after #{name}" unless operation.call == expected_value
    results[name] = { 'ips' => rates.fetch(0), 'allocated_bytes_per_op' => allocation }
  end
  puts JSON.generate(
    'backend' => actual,
    'runtime' => RUBY_DESCRIPTION,
    'java' => java.lang.System.get_property('java.version'),
    'os' => "#{java.lang.System.get_property('os.name')} #{java.lang.System.get_property('os.version')}",
    'arch' => java.lang.System.get_property('os.arch'),
    'processors' => java.lang.Runtime.get_runtime.available_processors,
    'jvm_options' => java.lang.management.ManagementFactory.get_runtime_mx_bean.input_arguments.to_a,
    'string_bytes' => { 'mixed' => mixed.bytesize, 'ascii' => ascii.bytesize, 'utf16' => utf16.bytesize },
    'results' => results
  )
  exit
end

abort 'Run this benchmark with JRuby' unless RUBY_ENGINE == 'jruby'
runs = Integer(ENV.fetch('RUNS', '3'))
abort 'RUNS must be positive' unless runs.positive?
root = File.expand_path('..', __dir__)
samples = []
Dir.mktmpdir('character-set-java-benchmark') do |directory|
  fallback = File.join(directory, 'lib')
  FileUtils.cp_r(File.join(root, 'lib'), fallback)
  File.unlink(File.join(fallback, 'character_set/character_set.jar'))
  runs.times do |index|
    backends = index.even? ? %w[fallback java] : %w[java fallback]
    backends.each do |backend|
      warn "Benchmark process #{index + 1}/#{runs}: #{backend}"
      library = backend == 'java' ? File.join(root, 'lib') : fallback
      stdout, stderr, status = Open3.capture3(Gem.ruby, __FILE__, 'worker', library, backend, chdir: directory)
      abort stderr unless status.success?
      warn stderr unless stderr.empty?
      samples << JSON.parse(stdout)
    end
  end
end

report = {
  'warmup_seconds_per_case' => Float(ENV.fetch('WARMUP', '10')),
  'measurement_seconds_per_case' => Float(ENV.fetch('TIME', '3')),
  'independent_processes_per_backend' => runs,
  'samples' => samples,
  'summary' => {}
}
samples.first.fetch('results').each_key do |name|
  summary = {}
  %w[fallback java].each do |backend|
    measurements = samples.select { |sample| sample.fetch('backend') == backend }
                          .map { |sample| sample.fetch('results').fetch(name) }
    rates = measurements.map { |measurement| measurement.fetch('ips') }.sort
    allocations = measurements.map { |measurement| measurement['allocated_bytes_per_op'] }.compact.sort
    middle = rates.length / 2
    median = rates.length.odd? ? rates[middle] : (rates[middle - 1] + rates[middle]) / 2.0
    summary[backend] = {
      'median_ips' => median, 'min_ips' => rates.first, 'max_ips' => rates.last,
      'median_allocated_bytes_per_op' => allocations.empty? ? nil : allocations[allocations.length / 2]
    }
  end
  summary['speedup'] = summary.fetch('java').fetch('median_ips') / summary.fetch('fallback').fetch('median_ips')
  report.fetch('summary')[name] = summary
end
puts JSON.pretty_generate(report)
