desc 'Run all IPS benchmarks'
task :benchmark do
  Dir["#{__dir__}/benchmarks/*.rb"].sort.each { |file| require file }
end

namespace :benchmark do
  desc 'Run all IPS benchmarks and store the comparison results in BENCHMARK.md'
  task :write_to_file do
    $store_comparison_results = {}

    Rake.application[:benchmark].invoke

    File.open("#{__dir__}/../BENCHMARK.md", 'w') do |f|
      f.puts "Results of `rake:benchmark` on #{RUBY_DESCRIPTION}", ''

      $store_comparison_results.each do |caption, result|
        f.puts '```',
               caption,
               '',
               result.strip.gsub(/ \(±[^)]+\) /, '').gsub(/(same-ish).*$/, '\1').lines[1..-1],
               '```'
      end
    end
  end
end
