# ruby-spec covers other cases

shared_examples :character_set_merge do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = variant[97, 98]
    set1.merge(set2)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#merge" do
  it_behaves_like :character_set_merge, CharacterSet
end

describe "CharacterSet::Pure#merge" do
  it_behaves_like :character_set_merge, CharacterSet::Pure
end
