# ruby-spec covers other cases

shared_examples :character_set_section do |variant|
  it 'does not create shared mutable state' do
    set1 = variant[96, 97]
    set2 = set1.section(from: 96, upto: 96)
    expect(Leto.shared_mutable_state?(set1, set2)).to eq false
  end
end

describe "CharacterSet#section" do
  it_behaves_like :character_set_section, CharacterSet
end

describe "CharacterSet::Pure#section" do
  it_behaves_like :character_set_section, CharacterSet::Pure
end
