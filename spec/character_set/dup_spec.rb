shared_examples :character_set_dup do |variant|
  it 'returns a new set with the same codepoints' do
    expect(variant[97, 98, 99].dup).to eq variant[97, 98, 99]
    orig = variant[97, 98, 99]
    expect(orig.dup.object_id).not_to eq(orig.object_id)
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set1.to_a # populate internal caches
    set2 = set1.dup
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#dup" do
  it_behaves_like :character_set_dup, CharacterSet
end

describe "CharacterSet::Pure#dup" do
  it_behaves_like :character_set_dup, CharacterSet::Pure
end
