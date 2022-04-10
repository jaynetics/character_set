require 'benchmark/ips'
require_relative '../../lib/character_set'
if RUBY_VERSION.to_f >= 3.0 && !RUBY_PLATFORM[/java/i]
  require 'sorted_set'
else
  require 'set'
end

def benchmark(caption: nil, cases: {})
  with_stdouts($stdout, string_io = StringIO.new) do
    puts caption
    Benchmark.ips do |x|
      cases.each { |label, callable| x.report(label, &callable) }
      x.compare!
    end
  end
  ($benchmark_results ||= {})[caption] = string_io.string
end

def with_stdouts(*ios)
  old_stdout = $stdout
  ios.define_singleton_method(:method_missing) { |*args| each { |io| io.send(*args) } }
  ios.define_singleton_method(:respond_to?) { |*args| IO.respond_to?(*args) }
  $stdout = ios
  yield
ensure
  $stdout = old_stdout
end
