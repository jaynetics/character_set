desc 'Update codepoint data for predefined sets, based on Onigmo'
task :sync_predefined_sets do
  %w[assigned emoji whitespace].each do |prop|
    require 'regexp_property_values'
    ranges = RegexpPropertyValues[prop].matched_ranges
    str = ranges.map { |r| "#{r.min.to_s(16)},#{r.max.to_s(16)}\n" }.join.upcase
    File.write("#{__dir__}/../lib/character_set/predefined_sets/#{prop}.cps", str, mode: 'w')
  end
end
