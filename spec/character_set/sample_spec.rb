shared_examples :character_set_sample do |variant|
  it 'returns a single element from the set as String' do
    sample = variant[97, 98, 99].sample
    expect(sample).to be_a(String)
    expect(['a', 'b', 'c']).to include(sample)
  end

  it 'returns nil for an empty set' do
    expect(variant[].sample).to be_nil
  end

  it 'returns multiple elements from the set as String if given a number' do
    sample = variant[97, 98, 99].sample(2)
    expect(sample.size).to eq 2
    expect(sample[0]).to be_a(String)
    expect(sample[1]).to be_a(String)
    expect(['a', 'b', 'c']).to include(sample[0])
    expect(['a', 'b', 'c']).to include(sample[1])
  end

  it 'returns [] for an empty set if given a number' do
    expect(variant[].sample(10)).to eq []
  end
end

describe "CharacterSet#sample" do
  it_behaves_like :character_set_sample, CharacterSet
end

describe "CharacterSet::Pure#sample" do
  it_behaves_like :character_set_sample, CharacterSet::Pure
end
