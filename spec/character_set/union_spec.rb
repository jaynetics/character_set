# ruby-spec covers other cases

shared_examples :character_set_union do |variant|
  %i[| + union].each do |method|
    it "does not create shared mutable state via ##{method}" do
      set1 = variant[96, 97]
      set2 = variant[97, 98]
      set3 = set1.send(method, set2)
      expect(Leto.shared_mutable_state?(set1, set2, set3)).to eq false
    end

    it "preserves the subclass and isolates result mutations via ##{method}" do
      subclass = Class.new(variant)
      source = subclass[1, 2]
      result = source | subclass[3]
      expect(result).to be_a subclass
      result.add(99)
      expect(source.to_a).to eq [1, 2]
    end
  end
end

describe "CharacterSet#|" do
  it_behaves_like :character_set_union, CharacterSet

  it 'unites with the Ruby implementation' do
    expect(CharacterSet[1, 2] | CharacterSet::Pure[2, 3]).to eq CharacterSet[1, 2, 3]
  end
end

describe "CharacterSet::Pure#|" do
  it_behaves_like :character_set_union, CharacterSet::Pure

  it 'unites with the native implementation' do
    expect(CharacterSet::Pure[2, 3] | CharacterSet[1, 2]).to eq CharacterSet::Pure[1, 2, 3]
  end
end
