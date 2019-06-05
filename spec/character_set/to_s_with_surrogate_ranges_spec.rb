shared_examples :character_set_to_s_with_surrogate_ranges do |variant|
  it 'calls CharacterSet::Writer::write_surrogate_ranges' do
    expect(CharacterSet::Writer)
      .to receive(:write_surrogate_ranges)
      .and_return(42)
    expect(variant[].to_s_with_surrogate_ranges).to eq 42
  end
end

describe "CharacterSet#to_s_with_surrogate_ranges" do
  it_behaves_like :character_set_to_s_with_surrogate_ranges, CharacterSet
end

describe "CharacterSet::Pure#to_s_with_surrogate_ranges" do
  it_behaves_like :character_set_to_s_with_surrogate_ranges, CharacterSet::Pure
end
