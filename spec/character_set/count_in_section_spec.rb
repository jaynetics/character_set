shared_examples :character_set_count_in_section do |variant|
  it 'returns the number of codepoints in the specified section' do
    expect(variant[3, 5, 7, 9].count_in_section(from: 0, upto: 9)).to eq 4
    expect(variant[3, 5, 7, 9].count_in_section(from: 4, upto: 8)).to eq 2
    expect(variant[3, 5, 7, 9].count_in_section(from: 6, upto: 6)).to eq 0
    expect(variant[3, 5, 7, 9].count_in_section(from: 0, upto: 1)).to eq 0
  end
end

describe "CharacterSet#count_in_section" do
  it_behaves_like :character_set_count_in_section, CharacterSet
end

describe "CharacterSet::Pure#count_in_section" do
  it_behaves_like :character_set_count_in_section, CharacterSet::Pure
end
