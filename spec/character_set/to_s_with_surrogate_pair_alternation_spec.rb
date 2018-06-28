shared_examples :character_set_to_s_with_surrogate_pair_alternation do |variant|
  it 'calls CharacterSet::Writer::write_surrogate_pair_alternation' do
    expect(CharacterSet::Writer)
      .to receive(:write_surrogate_pair_alternation)
      .and_return(42)
    expect(variant[].to_s_with_surrogate_pair_alternation).to eq 42
  end
end

describe "CharacterSet#to_s_with_surrogate_pair_alternation" do
  it_behaves_like :character_set_to_s_with_surrogate_pair_alternation, CharacterSet
end

describe "CharacterSet::Pure#to_s_with_surrogate_pair_alternation" do
  it_behaves_like :character_set_to_s_with_surrogate_pair_alternation, CharacterSet::Pure
end
