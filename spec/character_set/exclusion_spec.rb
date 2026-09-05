# ruby-spec covers other cases

shared_examples :character_set_exclusion do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[97, 98]
    set3 = set1 ^ set2
    expect(Leto.shared_mutable_state?(set1, set2, set3)).to eq false
  end
end

describe "CharacterSet#^" do
  it_behaves_like :character_set_exclusion, CharacterSet
end

describe "CharacterSet::Pure#^" do
  it_behaves_like :character_set_exclusion, CharacterSet::Pure
end
