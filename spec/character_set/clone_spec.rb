shared_examples :character_set_clone do |variant|
  it 'returns a new set with the same codepoints' do
    expect(variant[97, 98, 99].clone).to eq variant[97, 98, 99]
    orig = variant[97, 98, 99]
    expect(orig.clone.object_id).not_to eq(orig.object_id)
  end

  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set1.to_a # populate internal caches
    set2 = set1.clone
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
    set2.add(98)
    expect(set1.to_a).to eq [96, 97]
  end

  it 'preserves frozen state and members' do
    original = variant[1, 2].freeze
    clone = original.clone
    expect(clone).to be_frozen
    expect(clone.to_a).to eq [1, 2]
  end

  it 'can thaw a clone without sharing its backing storage' do
    original = variant[1, 2].freeze
    thawed = original.clone(freeze: false)
    expect(thawed).not_to be_frozen
    thawed.delete(1)
    expect(original.to_a).to eq [1, 2]
  end
end

describe "CharacterSet#clone" do
  it_behaves_like :character_set_clone, CharacterSet
end

describe "CharacterSet::Pure#clone" do
  it_behaves_like :character_set_clone, CharacterSet::Pure
end
