# ruby-spec covers other cases
#
shared_examples :character_set_subset_p do |variant|
  %i[subset? <= proper_subset? <].each do |method|
    it "does not create shared mutable state via ##{method}" do
      set1 = variant[96, 97]
      set2 = variant[96, 97, 98]
      set1.send(method, set2)
      expect(Leto.shared_mutable_state?(set1, set2)).to eq false
    end
  end
end

describe "CharacterSet#subset?" do
  it_behaves_like :character_set_subset_p, CharacterSet
end

describe "CharacterSet::Pure#subset?" do
  it_behaves_like :character_set_subset_p, CharacterSet::Pure
end
