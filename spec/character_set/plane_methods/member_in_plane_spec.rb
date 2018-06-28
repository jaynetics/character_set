shared_examples :character_set_member_in_plane do |variant|
  it 'returns true iff the CharacterSet has a member in the given plane' do
    expect(variant[97, 98, 99].member_in_plane?(0)).to be true
    expect(variant[97, 98, 99].member_in_plane?(1)).to be false
    expect(variant[70_000, 70_001].member_in_plane?(0)).to be false
    expect(variant[70_000, 70_001].member_in_plane?(1)).to be true
  end
end

describe "CharacterSet#member_in_plane?" do
  it_behaves_like :character_set_member_in_plane, CharacterSet
end

describe "CharacterSet::Pure#member_in_plane?" do
  it_behaves_like :character_set_member_in_plane, CharacterSet::Pure
end
