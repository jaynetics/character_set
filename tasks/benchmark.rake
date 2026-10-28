# frozen_string_literal: false

desc 'Run all IPS benchmarks'
task :benchmark do
  Dir["#{__dir__}/benchmarks/*.rb"].each { |file| load(file) }
end

namespace :benchmark do
  desc 'Compare the Java backend with the JRuby fallback in independent JVMs'
  task java: 'java:compile' do
    ruby File.expand_path('java_benchmark.rb', __dir__)
  end

  desc 'Run all IPS benchmarks and store the comparison results in BENCHMARK.md'
  task :write_to_file do
    Rake.application[:benchmark].invoke

    # extract comparison results from reports
    results = $benchmark_results
      .map { |caption, report| "```\n#{caption}\n\n#{report[/(?<=Comparison:).+/m].strip}\n```" }
      .join("\n")
      .gsub(/ \(±[^)]+\) |(?<=same-ish).*/, '') # remove some noise

    File.write "#{__dir__}/../BENCHMARK.md",
               "Results of `rake:benchmark` on #{RUBY_DESCRIPTION}\n\n#{results}\n"
  end
end
