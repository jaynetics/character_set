# ruby-spec covers other cases

shared_examples :character_set_replace do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[97, 98]
    set1.replace(set2)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#replace" do
  it_behaves_like :character_set_replace, CharacterSet
end

describe "CharacterSet::Pure#replace" do
  it_behaves_like :character_set_replace, CharacterSet::Pure
end
