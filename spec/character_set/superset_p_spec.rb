# ruby-spec covers other cases

shared_examples :character_set_superset_p do |variant|
  %i[superset? >= proper_superset? >].each do |method|
    it "does not create shared mutable state via ##{method}" do
      set1 = variant[96, 97, 98]
      set2 = variant[96, 97]
      set1.send(method, set2)
      expect(Leto.shared_mutable_state?(set1, set2)).to eq false
    end
  end
end

describe "CharacterSet#superset?" do
  it_behaves_like :character_set_superset_p, CharacterSet
end

describe "CharacterSet::Pure#superset?" do
  it_behaves_like :character_set_superset_p, CharacterSet::Pure
end
