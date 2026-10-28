# ruby-spec covers other cases

shared_examples :character_set_merge do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[97, 98]
    set1.merge(set2)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end

  it 'merges inclusive and exclusive Integer ranges' do
    expect(variant[].merge(97..99).to_a).to eq [97, 98, 99]
    expect(variant[].merge(97...99).to_a).to eq [97, 98]
  end
end

describe "CharacterSet#merge" do
  it_behaves_like :character_set_merge, CharacterSet

  it 'merges the pure implementation without sharing storage' do
    set = CharacterSet[1, 2]
    other = CharacterSet::Pure[2, 3]
    set.merge(other).delete(2)
    expect(other.to_a).to eq [2, 3]
  end
end

describe "CharacterSet::Pure#merge" do
  it_behaves_like :character_set_merge, CharacterSet::Pure
end
