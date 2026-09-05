# ruby-spec covers other cases

shared_examples :character_set_intersection do |variant|
  %i[& intersection].each do |method|
    it "does not create shared mutable state via ##{method}" do
      set1 = variant[96, 97]
      set2 = variant[97, 98]
      set3 = set1.send(method, set2)
      expect(Leto.shared_mutable_state?(set1, set2, set3)).to eq false
    end
  end
end

describe "CharacterSet#&" do
  it_behaves_like :character_set_intersection, CharacterSet
end

describe "CharacterSet::Pure#&" do
  it_behaves_like :character_set_intersection, CharacterSet::Pure
end
