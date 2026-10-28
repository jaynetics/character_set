# ruby-spec covers other cases

shared_examples :character_set_eql_p do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[96, 97]
    set1.eql?(set2)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end

  it 'ignores retained storage capacity after deletion' do
    set = variant[97, 0x10FFFF]
    set.delete(0x10FFFF)
    expect(set).to eql variant[97]
  end
end

describe "CharacterSet#eql?" do
  it_behaves_like :character_set_eql_p, CharacterSet
end

describe "CharacterSet::Pure#eql?" do
  it_behaves_like :character_set_eql_p, CharacterSet::Pure
end
