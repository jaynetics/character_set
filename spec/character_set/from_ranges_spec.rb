require 'regexp_parser'

shared_examples :character_set_from_ranges do |variant|
  it 'creates a set from all the given ranges' do
    expect(variant.from_ranges(4..6, 8..8)).to eq variant[4, 5, 6, 8]
    expect(variant.from_ranges(8..8, 4..6)).to eq variant[4, 5, 6, 8]
    expect(variant.from_ranges(3...1003).size).to eq 1000
    expect(variant.from_ranges(3...3).size).to eq 0
    expect(variant.from_ranges(3...1).size).to eq 0
  end

  it 'raises for open-ended Ranges', if: ruby_version_is_at_least('2.7') do
    expect { variant.from_ranges(Range.new(nil, 4)) }.to raise_error(StandardError)
    expect { variant.from_ranges(Range.new(4, nil)) }.to raise_error(StandardError)
  end
end

describe "CharacterSet::from_ranges" do
  it_behaves_like :character_set_from_ranges, CharacterSet
end

describe "CharacterSet::Pure::from_ranges" do
  it_behaves_like :character_set_from_ranges, CharacterSet::Pure
end
