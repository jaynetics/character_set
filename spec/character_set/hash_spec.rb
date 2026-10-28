shared_examples :character_set_hash do |variant|
  it 'is deterministic' do
    set = variant[97, 98, 99]
    expect(set.hash).to eq set.hash
  end
end

describe 'CharacterSet#hash' do
  it_behaves_like :character_set_hash, CharacterSet
end

describe 'CharacterSet::Pure#hash' do
  it_behaves_like :character_set_hash, CharacterSet::Pure
end
